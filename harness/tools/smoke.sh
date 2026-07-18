#!/usr/bin/env bash
# smoke.sh — Tier-2 Bootstrap-Smoke (Host-Docker + Netz, NICHT in gates). Verifiziert,
# dass der Bootstrap end-to-end laeuft, host-orchestriert (die Binary ruft selbst
# `docker run <d-check> --print-mk` und fetcht das Skelett per Netz — kein DinD, kein
# Netz im Container). `make gates` bleibt offline-schlank (LH-QA-01); dieser Smoke
# gehoert an DoD-Verify/CI/Wellen-Closure.
#
# Belege:
#   1. Binary aus der artifact-Stage extrahieren (Host).
#   2. `--lang go` bootstrappen: Doc-Gate (Runtime-Codegen, slice-002) + Template-
#      Baseline (slice-003) + Sprachskelett-Fetch (slice-004a, Netz).
#   3. Skelett gestaged? (slice-004a-Fetch-Beweis, .harness/skeleton/).
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

echo "smoke: 1/4 Binary aus der artifact-Stage auf den Host extrahieren ..."
docker build --build-arg GO_VERSION="$GO_VERSION" \
	--target artifact --output "type=local,dest=$tmpbin" .

echo "smoke: 2/4 Bootstrap (--lang go): Doc-Gate + Templates + Skelett-Fetch (Netz) ..."
( cd "$tmprepo" && "$tmpbin/ai-harness-init" --lang go --name smoke )

echo "smoke: 3/4 Skelett gestaged? (slice-004a) ..."
if [ ! -f "$tmprepo/.harness/skeleton/Makefile" ]; then
	echo "smoke: FEHLER — Sprachskelett nicht nach .harness/skeleton/ gestaged" >&2
	exit 1
fi

echo "smoke: 4/4 emittiertes docs-check laeuft + akzeptiert die Config ..."
out="$(make -C "$tmprepo" -f d-check.mk docs-check 2>&1 || true)"
if ! printf '%s\n' "$out" | grep -q "geprüft"; then
	echo "smoke: FEHLER — d-check lief nicht (Config-Crash / halluzinierte Config?):" >&2
	printf '%s\n' "$out" >&2
	exit 1
fi
printf '%s\n' "$out" | grep -E "geprüft|Befund"

echo "smoke: OK — Bootstrap laeuft, Skelett gestaged, Doc-Gate-Config valide."
echo "smoke: HINWEIS — 0 Befunde out-of-the-box (voller Green-Run) ist slice-005 (LH-FA-01)."

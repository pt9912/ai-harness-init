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
#      Baseline (slice-003) + Sprachskelett-Fetch (slice-004a, Netz) + vendored
#      Baseline mit Verifier (slice-022a, ZWEITER Netz-Fetch: Release-Asset).
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

echo "smoke: 3/4 Skelett gestaged? (slice-004a) + Templates emittiert? (slice-022b) ..."
if [ ! -f "$tmprepo/.harness/skeleton/Makefile" ]; then
	echo "smoke: FEHLER — Sprachskelett nicht nach .harness/skeleton/ gestaged" >&2
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

#!/usr/bin/env bash
# smoke.sh — Tier-2 Bootstrap-Smoke (Host-Docker + Netz, NICHT in gates). Verifiziert,
# dass der Bootstrap end-to-end laeuft, host-orchestriert (die Binary ruft selbst
# `docker run <d-check> --print-mk`, generiert das Skelett lokal und fetcht die
# Baseline per Netz — kein DinD, kein Netz im Container). `make gates` bleibt
# offline-schlank (LH-QA-01); dieser Smoke
# gehoert an DoD-Verify/CI/Wellen-Closure.
#
# Belege:
#   1. Natives Release-Binary auf den Host ziehen (`make artifact`, docker cp).
#   2. `--lang go` bootstrappen: Doc-Gate (Runtime-Codegen, slice-002) + Template-
#      Baseline (slice-003) + Sprachskelett-Generierung (slice-023, lokal/
#      deterministisch, kein Netz) + vendored Baseline mit Verifier (slice-022a,
#      Netz-Fetch: Release-Asset).
#   3. Skelett an den Ziel-Root verdrahtet (slice-004b) + transientes
#      .harness/skeleton/ entfernt + Template-Schicht emittiert (slice-022b).
#   4. Emittiertes d-check laeuft und akzeptiert die Config (kein Config-Crash).
#   5. Verdrahtetes Makefile bindet d-check.mk ein (MR-010) + Go-Gates am
#      Ziel-Root gruen (lint/build/test).
#
# GEPRUEFT (slice-028): das emittierte docs-check meldet 0 Befunde out-of-the-box
# (Schritt 4) — die drei frueheren Befunde (2 derivative Indexe + 1 Roadmap-Zeile)
# sind weg. NICHT hier: der zusammengefuehrte make-gates-E2E im Ziel (docs-check +
# Go-Gates in EINEM Lauf) — das ist slice-024 (LH-FA-01 Happy-Path).
set -euo pipefail

GO_VERSION="${GO_VERSION:-1.26.4}"
tmpbin="$(mktemp -d)"
tmprepo="$(mktemp -d)"
cleanup() { rm -rf "$tmpbin" "$tmprepo"; }
trap cleanup EXIT
# mktemp -d liefert 0700; der d-check-Container laeuft als Nicht-Root und kann den
# 0700-Mount nicht traversieren. Ein echtes Adopter-Git-Repo hat 0755.
chmod 755 "$tmprepo"

echo "smoke: 1/5 natives Release-Binary auf den Host extrahieren (make artifact) ..."
make artifact DEST="$tmpbin" GO_VERSION="$GO_VERSION"

echo "smoke: 2/5 Bootstrap (--lang go): Doc-Gate + Templates + Skelett-Generierung (lokal) ..."
( cd "$tmprepo" && "$tmpbin/ai-harness-init" --lang go --name smoke )

echo "smoke: 3/5 Skelett an den Ziel-Root verdrahtet? (slice-004b) + Templates emittiert? (slice-022b) ..."
if [ ! -f "$tmprepo/Makefile" ] || [ ! -f "$tmprepo/go.mod" ]; then
	echo "smoke: FEHLER — Sprachskelett nicht an den Ziel-Root verdrahtet (Makefile/go.mod fehlt)" >&2
	exit 1
fi
# Root-README (slice-005, LH-FA-05): aus project-readme.template.md emittiert.
if [ ! -f "$tmprepo/README.md" ]; then
	echo "smoke: FEHLER — Root-README nicht emittiert (slice-005, LH-FA-05)" >&2
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
# LH-FA-02 0.8.0: emittiert werden Singletons (-> .md) und die Struktur-.gitkeep;
# wiederkehrende Vorlagen und derivative Indexe NICHT (referenziert aus vendored
# bzw. Fuelle-wenn-Inhalt-da). Je ein positiver Vertreter beider Klassen:
for rel in AGENTS.md docs/plan/adr/.gitkeep docs/plan/planning/in-progress/roadmap.md; do
	if [ ! -f "$tmprepo/$rel" ]; then
		echo "smoke: FEHLER — Template-Schicht unvollstaendig: $rel fehlt" >&2
		exit 1
	fi
done
# Gegenprobe: was NICHT emittiert werden darf. (a) wiederkehrende Vorlagen (0.8.0:
# referenziert, nicht co-located) und (b) derivative Indexe (broken Platzhalter-
# Links). (c) die In-Scope-Regel — geprueft an den Namen, die der Emitter WIRKLICH
# schriebe, nicht den Quell-Namen: singletonTarget haengt ".md" an, aus `README.md`
# wuerde `README.md.md`. Die erste Fassung prueste `README.md` und war unter der
# Mutation, gegen die sie gerichtet ist, wirkungslos (Review-Befund slice-026 F-2 —
# Falsch-Beispiel 1 aus AGENTS Paragraph 3.6, woertlich).
for rel in \
	docs/plan/planning/slice.template.md docs/plan/adr/NNNN-titel.template.md \
	docs/plan/adr/README.md docs/plan/carveouts/README.md \
	README.md.md Makefile.md .d-check.yml.md project-readme.md .harness/skills/reviewer.md; do
	if [ -e "$tmprepo/$rel" ]; then
		echo "smoke: FEHLER — Artefakt emittiert, das nicht darf (0.8.0): $rel" >&2
		exit 1
	fi
done

echo "smoke: 4/5 emittiertes docs-check laeuft + meldet 0 Befunde out-of-the-box (slice-028, LH-QA-01) ..."
dc_rc=0
out="$(make -C "$tmprepo" -f d-check.mk docs-check 2>&1)" || dc_rc=$?
# Erst: lief es ueberhaupt (kein Config-Crash)?
if ! printf '%s\n' "$out" | grep -q "geprüft"; then
	echo "smoke: FEHLER — d-check lief nicht (Config-Crash / halluzinierte Config?):" >&2
	printf '%s\n' "$out" >&2
	exit 1
fi
printf '%s\n' "$out" | grep -E "geprüft|Befund" || true
# Dann: 0 Befunde. docs-check ist ein Gate -> Exit != 0 heisst Befunde. Das ist der
# slice-028-Kern: das emittierte Repo ist out-of-the-box gate-sicher (die drei
# frueheren Befunde — 2 derivative Indexe + 1 Roadmap-Zeile — sind weg). Ein blosses
# "lief durch" waere stilles Gruen (LH-QA-01): der Exit-Code ist die Aussage.
if [ "$dc_rc" -ne 0 ]; then
	echo "smoke: FEHLER — emittiertes docs-check meldet Befunde (nicht out-of-the-box gate-sicher, slice-028/LH-QA-01):" >&2
	printf '%s\n' "$out" >&2
	exit 1
fi

echo "smoke: 5/5 verdrahtetes Skelett am Ziel-Root: d-check.mk eingebunden + Go-Gates gruen? ..."
# slice-004b: das Skelett liegt jetzt am Ziel-Root, das Makefile bindet d-check.mk
# ein (MR-010) — ein make gates statt zweier Gate-Quellen. Verdrahtung strukturell:
if ! grep -q '^include d-check.mk$' "$tmprepo/Makefile"; then
	echo "smoke: FEHLER — generiertes Makefile bindet d-check.mk NICHT ein (MR-010-Verdrahtung fehlt)" >&2
	exit 1
fi
# E2E: die Go-Gates (lint/build/test) am Ziel-Root real gruen — NICHT `make gates`
# in EINEM Lauf (docs-check pruefen wir separat in Schritt 4; der zusammengefuehrte
# make-gates-E2E im Ziel ist slice-024). Belegt, dass die kuratiert-reiche
# .golangci.yml + main.go am Root zusammenpassen (Host-Docker).
skel_out="$( make -C "$tmprepo" lint build test 2>&1 )" || {
	echo "smoke: FEHLER — die Go-Gates des verdrahteten Skeletts sind rot (lint/build/test):" >&2
	printf '%s\n' "$skel_out" | tail -25 >&2
	exit 1
}

echo "smoke: OK — Bootstrap laeuft, Skelett verdrahtet + Go-Gates gruen, emittiertes docs-check 0 Befunde out-of-the-box (slice-028)."
echo "smoke: HINWEIS — der zusammengefuehrte make-gates-E2E im Ziel (docs-check + Go-Gates in EINEM Lauf) ist slice-024 (LH-FA-01)."

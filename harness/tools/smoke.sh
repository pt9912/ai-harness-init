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
#   5. Root-Makefile ist der Aggregator (include harness/mk/*.mk), das Doc-Gate-
#      Fragment bindet d-check.mk ein (slice-034) + Go-Gates am Ziel-Root gruen.
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
for rel in AGENTS.md docs/plan/adr/.gitkeep docs/plan/planning/in-progress/roadmap.md .harness/skills/reviewer.md; do
	if [ ! -f "$tmprepo/$rel" ]; then
		echo "smoke: FEHLER — Template-Schicht unvollstaendig: $rel fehlt" >&2
		exit 1
	fi
done
# Durchsetzungsschicht (slice-031/032, LH-FA-06/ADR-0006): Gate-Nachweis + Stop-Hook
# + Command-Guard + awk-Extraktor als Tool-als-Quelle emittiert. Positive Vertreter
# beider Zielorte (tools/harness/ + .claude/) und der Stempel-Ignore. Der geschlossene
# Nachweis-Kreis + das Guard-Verhalten (blockt/laesst durch) sind Voll-Smoke
# (full-smoke.sh), nicht hier.
for rel in tools/harness/record-gates.sh tools/harness/working-tree-hash.sh \
	.claude/hooks/stop-require-gates.sh .claude/settings.json .harness/.gitignore \
	.claude/hooks/pretooluse-command-guard.sh tools/harness/extract-command.awk; do
	if [ ! -f "$tmprepo/$rel" ]; then
		echo "smoke: FEHLER — Durchsetzungsschicht unvollstaendig: $rel fehlt (slice-031/032)" >&2
		exit 1
	fi
done
# slice-032: die settings.json verdrahtet jetzt BEIDE Hooks — der Guard (PreToolUse)
# neben dem Stop-Hook. Ohne die PreToolUse-Verdrahtung liefe der emittierte Guard nie.
if ! grep -q "PreToolUse" "$tmprepo/.claude/settings.json"; then
	echo "smoke: FEHLER — settings.json verdrahtet PreToolUse (Command-Guard) nicht (slice-032)" >&2
	exit 1
fi
# Der Platzhalter @@BLOCKED_SET@@ darf im Ziel nicht zurueckbleiben (zahnloser Guard).
if grep -q "@@BLOCKED_SET@@" "$tmprepo/.claude/hooks/pretooluse-command-guard.sh"; then
	echo "smoke: FEHLER — Guard traegt den @@BLOCKED_SET@@-Platzhalter (Substitution fehlte, slice-032)" >&2
	exit 1
fi
# Workflow-Commands (slice-033, LH-FA-08): die Slash-Command-Anleitung im Ziel.
for rel in .claude/commands/implement-slice.md .claude/commands/plan-welle.md \
	.claude/commands/close-welle.md; do
	if [ ! -f "$tmprepo/$rel" ]; then
		echo "smoke: FEHLER — Workflow-Command fehlt: $rel (slice-033)" >&2
		exit 1
	fi
done
# Kein ai-harness-init-interner Leak in den emittierten Commands (LH-FA-08 nicht 1:1 hart).
if grep -rqE 'ai-harness-init|make mutate|test/mutations' "$tmprepo/.claude/commands/"; then
	echo "smoke: FEHLER — emittierter Command traegt ai-harness-init-interne Referenz (slice-033)" >&2
	exit 1
fi
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
	README.md.md Makefile.md .d-check.yml.md project-readme.md; do
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

echo "smoke: 5/5 verdrahtetes Skelett am Ziel-Root: Aggregator + Fragmente + Go-Gates gruen? ..."
# slice-034: die Root-Makefile ist ein Aggregator (include harness/mk/*.mk); das
# Doc-Gate-Fragment harness/mk/doc-gate.mk bindet d-check.mk ein — ein make gates statt
# zweier Gate-Quellen. Verdrahtung strukturell, beide Ebenen:
if ! grep -q '^include harness/mk/\*\.mk$' "$tmprepo/Makefile"; then
	echo "smoke: FEHLER — Root-Makefile ist kein Aggregator (include harness/mk/*.mk fehlt, slice-034)" >&2
	exit 1
fi
if ! grep -q '^include d-check.mk$' "$tmprepo/harness/mk/doc-gate.mk"; then
	echo "smoke: FEHLER — Doc-Gate-Fragment bindet d-check.mk NICHT ein (slice-034)" >&2
	exit 1
fi
# slice-034: die Gate-Fragmente je Belang liegen unter harness/mk/ (der Aggregator
# bindet sie per Glob ein). Positive Vertreter aller vier Belange.
for rel in harness/mk/go.mk harness/mk/doc-gate.mk harness/mk/baseline.mk harness/mk/enforce.mk; do
	if [ ! -f "$tmprepo/$rel" ]; then
		echo "smoke: FEHLER — Gate-Fragment fehlt: $rel (slice-034)" >&2
		exit 1
	fi
done
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

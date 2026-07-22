#!/usr/bin/env bash
# full-smoke.sh — Voll-E2E-Smoke (slice-024, LH-FA-01 Happy-Path + LH-QA-01).
#
# Bootstrap in ein tmp-Repo, dann dort `make gates` — der EINE Einstiegspunkt, den
# ein Adopter faehrt. Das ist der Beweis, den welle-01 aufschob und welle-02
# weitergab: ein frisch gebootstrapptes Zielrepo faehrt `make gates` out-of-the-box
# gruen, ohne Nacharbeit.
#
# Abgrenzung zum Tier-2 `make smoke` (slice-002): jener prueft die Bootstrap-SCHRITTE
# einzeln (Templates emittiert, docs-check-Config valide + 0 Befunde, Go-Gates
# getrennt via `-f d-check.mk` bzw. `lint build test`). DIESER faehrt den
# ZUSAMMENGEFUEHRTEN `make gates` (MR-010: docs-check + Go-Gates kombiniert ueber die
# d-check.mk-Verdrahtung, `gates: docs-check` an `gates: lint build test` angehaengt)
# — die Sicht des echten Nutzers, die `make smoke` bewusst NICHT nimmt.
#
# Host-Docker + ggf. Netz-Pull -> NICHT in `make gates` (offline-schlank, LH-QA-01);
# gehoert an DoD-Verify/CI/Wellen-Closure. Logik in harness/tools/ (shell-lint deckt sie).
set -euo pipefail

GO_VERSION="${GO_VERSION:-1.26.4}"
tmpbin="$(mktemp -d)"
tmprepo="$(mktemp -d)"
cleanup() { rm -rf "$tmpbin" "$tmprepo"; }
trap cleanup EXIT
# mktemp -d liefert 0700; der d-check-Container laeuft als Nicht-Root und kann den
# 0700-Mount nicht traversieren. Ein echtes Adopter-Git-Repo hat 0755.
chmod 755 "$tmprepo"

echo "full-smoke: 1/3 Binary aus der artifact-Stage auf den Host extrahieren ..."
docker build --build-arg GO_VERSION="$GO_VERSION" \
	--target artifact --output "type=local,dest=$tmpbin" .

echo "full-smoke: 2/3 Bootstrap (--lang go --name full-smoke) in ein leeres tmp-Repo ..."
( cd "$tmprepo" && "$tmpbin/ai-harness-init" --lang go --name full-smoke )

echo "full-smoke: 3/3 im Ziel: make gates (der zusammengefuehrte Einstiegspunkt, MR-010) ..."
gates_rc=0
gates_out="$( make -C "$tmprepo" gates 2>&1 )" || gates_rc=$?
printf '%s\n' "$gates_out"
if [ "$gates_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — make gates im emittierten Repo ist NICHT Exit 0 (LH-FA-01 Happy-Path verletzt)." >&2
	exit 1
fi

# LH-QA-01: `make gates` muss die BEHAUPTETEN Gates WIRKLICH fahren, nicht still eine
# Teilmenge. Belege im Lauf-Output, dass alle vier gelaufen sind: die drei Go-Gates
# (Dockerfile-Stages, per make-Recipe-Echo `--target <stage>`) UND das Doc-Gate
# (d-check druckt "… Datei(en) geprueft"). Ein gruenes make gates ueber einer stillen
# Teilmenge waere ein halluziniertes Gate. Der "geprueft"-Marker deckt zugleich die
# MR-010-Verdrahtung: ohne den `gates: docs-check`-Anhang liefe docs-check gar nicht
# mit, der Marker fehlte -> hier rot (nicht bloss Exit 0 pruefen). "geprueft" (statt
# "Befund") ist der kanonische "d-check lief"-Marker, auf den auch harness/tools/
# smoke.sh keyt — er stammt aus der d-check-Laufzeit, nicht aus dem Recipe-Echo.
missing=""
for marker in "--target lint" "--target build" "--target test" "geprüft"; do
	printf '%s\n' "$gates_out" | grep -qF -- "$marker" || missing="$missing [$marker]"
done
if [ -n "$missing" ]; then
	echo "full-smoke: FEHLER — make gates lief gruen, aber ohne Beleg fuer:$missing — stilles Teilmengen-Gate? (LH-QA-01)" >&2
	exit 1
fi

echo "full-smoke: OK — frisch gebootstrapptes Repo faehrt make gates out-of-the-box gruen (lint/build/test + docs-check zusammengefuehrt), Exit 0 (LH-FA-01/LH-QA-01)."

#!/usr/bin/env bash
# Tier-2 Emit-Smoke (Test-Arch-Entscheid slice-002): extrahiert das Binary aus der
# Dockerfile-artifact-Stage auf den HOST, emittiert die Doc-Gate-Baseline in ein
# tmp-Repo und laesst dort das EMITTIERTE `make -f d-check.mk docs-check` real laufen
# (docker run d-check) — der ehrliche Green-Run (DoD-4), host-orchestriert.
#
# Warum Host statt Container: die Binary erzeugt d-check.mk zur Laufzeit via
# `docker run <d-check> --print-mk`; liefe sie im Container, waere das DinD. Auf dem
# Host hat sie das geforderte Docker (LH-QA-03). NICHT in `make gates` (schwerer,
# seltener Lauf mit Docker/Netz-Pull; make gates bleibt offline-schlank, LH-QA-01).
set -euo pipefail

GO_VERSION="${GO_VERSION:-1.26.4}"
tmpbin="$(mktemp -d)"
tmprepo="$(mktemp -d)"
cleanup() { rm -rf "$tmpbin" "$tmprepo"; }
trap cleanup EXIT
# mktemp -d liefert 0700; der d-check-Container laeuft als Nicht-Root und kann den
# 0700-Mount nicht traversieren (-> "permission denied"). Ein echtes Adopter-Git-Repo
# hat 0755 — der Smoke bildet das nach, statt eine Tool-"Loesung" fuer ein reines
# Fixture-Perm-Artefakt zu erfinden.
chmod 755 "$tmprepo"

echo "smoke: 1/3 Binary aus der artifact-Stage auf den Host extrahieren ..."
docker build --build-arg GO_VERSION="$GO_VERSION" \
	--target artifact --output "type=local,dest=$tmpbin" .

echo "smoke: 2/3 Doc-Gate-Baseline ins tmp-Repo emittieren (Runtime-Codegen, Host-Docker) ..."
( cd "$tmprepo" && "$tmpbin/ai-harness-init" --lang go --name smoke )

echo "smoke: 3/3 emittiertes docs-check im tmp-Repo real laufen lassen ..."
if [ ! -f "$tmprepo/.d-check.yml" ] || [ ! -f "$tmprepo/d-check.mk" ]; then
	echo "smoke: FEHLER — emittierte Dateien fehlen im tmp-Repo" >&2
	exit 1
fi
make -C "$tmprepo" -f d-check.mk docs-check

echo "smoke: OK — emittiertes docs-check im tmp-Repo Exit 0."

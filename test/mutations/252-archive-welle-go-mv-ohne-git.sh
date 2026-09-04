#!/usr/bin/env bash
# files: cmd/ai-harness-init/archive_welle.go
# expect: TestArchiveWelleEchtArchiviertUndSetztZweiCommits
# verify: test-go
#
# NIMMT DEM ERSTEN SCHREIBENDEN GIT-AUFRUF SEINEN PROZESS: `Mv` meldet Erfolg und
# bewegt nichts. Die Reihenfolge darueber bleibt heil — Move-Schleife, Commit 1,
# Zip, Stubs, Nachzug, Commit 2 —, nur laeuft Commit 1 danach ueber einen leeren
# Index und faellt.
#
# Das ist NICHT Fall 245. Der nimmt den Move-COMMIT aus der Reihenfolge und wird
# an einem Fall rot, der die vier Operationen als Schnittstelle mitschreibt. Ein
# Mitschreiber sieht, DASS `Mv` gerufen wurde, nie ob dahinter `git mv` steht;
# diese Haelfte traegt allein ein Lauf gegen ein echtes Repo.
set -euo pipefail
sed -i 's|^func (g gitSchreibend) Mv(alt, neu string) error { return g.lauf("mv", "--", alt, neu) }$|func (g gitSchreibend) Mv(alt, neu string) error { _, _ = alt, neu; return nil }|' \
	cmd/ai-harness-init/archive_welle.go

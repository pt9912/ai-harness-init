#!/usr/bin/env bash
# files: cmd/ai-harness-init/archive_welle.go
# expect: TestArchiveWelleAltbestandOhneKennungEndetAlsAufrufFehler
# verify: test-go
#
# DIE FEHLENDE KENNUNG ENDET ALS LAUFZEIT-FEHLER (Exit 1) statt als Aufruf-Fehler
# (Exit 2): die Usage nennt Exit 2 fuer einen falschen Aufruf, und ein Aufrufer, der
# die zwei Klassen trennt, liest den fehlenden Parameter als kaputtes Repo
# (ADR-0090 Festlegung 1). Der Fall meldet "Exit 1, want 2".
set -euo pipefail
sed -i 's/^\t\tif errors\.Is(err, archive\.ErrKennungFehlt) {$/\t\tif false \&\& errors.Is(err, archive.ErrKennungFehlt) {/' cmd/ai-harness-init/archive_welle.go
grep -q '^		if false && errors.Is(err, archive.ErrKennungFehlt) {$' cmd/ai-harness-init/archive_welle.go

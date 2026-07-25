#!/usr/bin/env bash
# files: internal/emit/archgate.go
# expect: TestArchGateMk_RootAndScoped
#
# Weitet den Mount des modul-scoped Arch-Gates vom Modul-Verzeichnis auf das ganze
# Ziel-Repo (der Pfad-Anteil hinter CURDIR faellt weg). Die modul-relative Schicht-Config
# traefe dann nichts mehr am erwarteten Ort — im Mono-Repo liefe a-check mit der Config
# des einen Moduls ueber allen anderen. Der Anker ist bewusst dollar-frei (SC2016).
set -euo pipefail
sed -i 's|(CURDIR)/" + path|(CURDIR)" + path|' internal/emit/archgate.go

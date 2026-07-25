#!/usr/bin/env bash
# files: internal/emit/archgate.go
# expect: TestArchGateMk_RootAndScoped
#
# Kappt den Trenner zwischen CURDIR und dem Modul-Pfad im Mount des modul-scoped
# Arch-Gates: aus <repo>/apps/hex wird <repo>apps/hex. Der Mount zeigt dann nicht mehr
# auf das Modul — die modul-relative Schicht-Config traefe nichts am erwarteten Ort.
# (Praezisiert nach Review F-7: die Mutation weitet den Scope nicht, sie zerstoert den
# Pfad; rot wird der Waechter so oder so, aber der Kopf muss die Wirkung treffen.)
# Der Anker ist bewusst dollar-frei (SC2016).
set -euo pipefail
sed -i 's|(CURDIR)/" + path|(CURDIR)" + path|' internal/emit/archgate.go

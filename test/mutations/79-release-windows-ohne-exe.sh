#!/usr/bin/env bash
# files: Makefile
# expect: Windows-Artefakte tragen .exe
#
# Nimmt die .exe-Endung vom Windows-Artefakt. Der Bau bleibt gruen, die Datei ist ein
# gueltiges PE32+-Binary — sie laesst sich unter Windows nur nicht ohne Umbenennen
# starten. Ein Fehler, der erst beim Anwender sichtbar wuerde.
set -euo pipefail
sed -i 's|ext=".exe"|ext=""|' Makefile

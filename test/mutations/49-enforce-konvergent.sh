#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestEnforce_IdempotenzKlasseJePfad
#
# DER KONVERGENTE ZWEIG WIRD UEBERSPRUNGEN: der Arm fuer Konvergent geht auf den
# skip-if-present-Writer. Ein Re-Lauf laesst eine adopter-modifizierte Mechanik-Datei damit
# stehen, statt sie kanonisch neu zu schreiben.
#
# Getroffen ist die Klasse, nicht ein einzelner Pfad: der Arm traegt sie fuer JEDEN
# konvergenten Eintrag der Aufzaehlung. Der Waechter muss rot werden, weil er je Pfad die
# Richtung SEINER Klasse faehrt — ueber einer Menge, die nur noch ueberspringt, faellt die
# Heilungs-Haelfte aus.
set -euo pipefail
sed -i '/case Konvergent:/{n;s/writeFileMode/writeSkipIfPresent/}' internal/emit/enforce.go

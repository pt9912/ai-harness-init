#!/usr/bin/env bash
# files: cmd/ai-harness-init/main.go
# expect: TestUsage_NenntJedeSpracheUndIhrenKnopf
#
# Der Knopf SKEL_CSHARP_VERSION verschwindet aus der Haupthilfe -> der oeffentliche Vertrag der
# Sprach-Achse nennt den Versions-Knopf einer Sprache mit gen-Profil nicht (LH-FA-04).
set -euo pipefail
sed -i 's/SKEL_CSHARP_VERSION = Tag des dotnet-sdk-Images/Tag des dotnet-sdk-Images/' cmd/ai-harness-init/main.go

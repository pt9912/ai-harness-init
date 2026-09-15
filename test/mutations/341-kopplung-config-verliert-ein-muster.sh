#!/usr/bin/env bash
# files: .d-check.yml
# expect: kopplung: Traeger und Config tragen dieselbe Muster-Menge
# verify: test-bats
#
# NIMMT DER CONFIG EIN MUSTER: der MR-Eintrag faellt aus `commits.id-patterns`,
# der Traeger fuehrt ihn weiter. Die zwei Fassungen derselben Regel weichen
# damit auseinander, und der Traeger prueft strenger als das Gate.
#
# WARUM DIESE RICHTUNG EINEN EIGENEN FALL BRAUCHT: der Beleg je Config-Muster
# (derselbe Block) sieht nur EINE Richtung — faellt ein Config-Muster weg, hat
# er weniger zu pruefen und bleibt gruen. Getragen wird die Kopplung von der
# Mengen-Gleichheit in test/commit-msg-hook.bats; ohne sie waere die Zusage
# "in beide Richtungen" eine Behauptung.
#
# DIE GEGENRICHTUNG HAT IHREN EIGENEN FALL DANEBEN (der Traeger fuehrt ein
# Muster MEHR als die Config); beide Richtungen sind einmal von Hand rot
# gesehen und je durch einen kuratierten Fall gehalten.
#
# WARUM die bats-Stufe die schmalste ausreichende ist: gemessen werden zwei
# Textfassungen gegeneinander — kein Docker, kein d-check-Image.
set -euo pipefail
sed -i "/^    - 'MR-/d" .d-check.yml

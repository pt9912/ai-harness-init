#!/usr/bin/env bash
# files: internal/emit/templates/enforce/hooks-install.mk
# expect: TestHooksInstallFragment_TraegtDieKlasseSeinesPfades
#
# DAS AKTIVIERUNGS-FRAGMENT VERLIERT DEN KLASSEN-SATZ: es nennt dem Aktivierer danach nicht
# mehr, dass das Werkzeug seinen Traeger nur ablegt, wo der Pfad frei ist. Der Pfad liest sich
# dann als Werkzeug-Eigentum — und der Adopter, dessen eigener Traeger dort liegt, sucht den
# Grund an der falschen Stelle.
set -euo pipefail
sed -i '/^# DIE KLASSE DES TRAEGERS IST SKIP-IF-PRESENT (ADR-0054)\./,/^# geschrieben und liegt auch in diesem Fall bereit\.$/d' \
	internal/emit/templates/enforce/hooks-install.mk

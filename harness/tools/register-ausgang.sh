#!/usr/bin/env bash
# register-ausgang.sh — haelt das Beobachtungs-Register gegen seine Ausgangs-Regel: ein Eintrag
# ueber der 3x-Schwelle traegt in state.md einen der drei Ausgaenge (verkoerpert · geplant ·
# gestrichen), nicht `offen`. Bindung: die Regel aus ADR-0049, der Zeitpunkt (der Ausgang steht
# mit dem Beleg, der die Schwelle hebt) aus ADR-0085 (Proposed), die Zaehlung `evidence/*.md`
# aus ADR-0069; Wortlaut der Regel in docs/plan/planning/observations/README.md.
#
# Aufruf: register-ausgang.sh [<wurzel>]   (Default: docs/plan/planning/observations)
#
# ZUSAGE: Jedes Verzeichnis <wurzel>/BEO-*/<slug>/ mit mindestens drei Dateien evidence/*.md,
# dessen state.md in ihrer Zeile `**Stand:**` als erstes Wort keinen der drei Ausgaenge fuehrt, ist
# ein Befund — namentlich, mit Belegzahl und gelesenem Stand-Wort. Fehlt state.md oder ihre
# Stand-Zeile, ist das ebenso ein Befund. Die Stand-Zeile muss eindeutig sein: fuehrt state.md
# mehr als eine Zeile `**Stand:**`, ist das ein Befund, statt dass die erste entscheidet — eine
# zitierte Zeile vor der echten koennte sonst einen Ausgang vortaeuschen. Eine Ausnahmeliste gibt
# es nicht: der Sensor fuehrt keine Liste erwarteter Eintraege (Slice-Plan §3,
# slice-register-ueber-der-schwelle-bekommt-seinen-waechter).
# Gezaehlt werden Dateien evidence/*.md, nicht das Verzeichnis (ADR-0069 Folgepflicht 2): ein
# leeres evidence/ und eine Nicht-.md-Datei darin zaehlen nicht. Stand und Zahl kommen beide aus
# dem Dateisystem.
# Ein leerer Pruefbereich ist kein Gruen: fehlt die Wurzel oder trifft `BEO-*/*/` kein
# Verzeichnis (umbenanntes Kuerzel, geaenderte Tiefe), bricht der Lauf mit Exit 2 ab.
#
# GRENZE: Geprueft ist das Stand-Wort, nicht ob der Ausgang traegt — ein `geplant` ohne
# aufloesbare Kennung und ein `verkoerpert` ohne Zielort bleiben still
# (BEO-ALL/ausgang-nennt-traeger-der-nicht-traegt). Ein Verzeichnis ohne Beleg (zweite Haelfte
# der Register-Paarung, ADR-0069 Festlegung 2) liegt unter der Schwelle und ist nicht
# Gegenstand dieses Waechters; die Eindeutigkeit der Stand-Zeile prueft er nur ueber der Schwelle.
#
# Exit: 0 ohne Befund · 1 mit Befund · 2 Wurzel fehlt oder kein Eintrag gefunden.
# Wirkungs-Test: test/register-ausgang.bats.
set -euo pipefail

root="${1:-docs/plan/planning/observations}"
if [ ! -d "$root" ]; then
  echo "register-ausgang: Wurzel '$root' fehlt — nichts geprueft" >&2
  exit 2
fi

shopt -s nullglob
eintraege=0
ueber=0
befunde=0
for d in "$root"/BEO-*/*/; do
  d="${d%/}"
  eintraege=$((eintraege + 1))
  belege=0
  for f in "$d"/evidence/*.md; do
    [ -f "$f" ] && belege=$((belege + 1))
  done
  [ "$belege" -ge 3 ] || continue
  ueber=$((ueber + 1))
  name="${d#"$root"/}"
  if [ ! -f "$d/state.md" ]; then
    echo "register-ausgang: $name: $belege Belege (evidence/*.md), state.md fehlt — ueber der 3x-Schwelle ohne Ausgang"
    befunde=$((befunde + 1))
    continue
  fi
  stand_zeilen="$(grep -c '^\*\*Stand:\*\*' "$d/state.md" || true)"
  if [ "$stand_zeilen" -gt 1 ]; then
    echo "register-ausgang: $name: $belege Belege (evidence/*.md), $stand_zeilen Zeilen '**Stand:**' in state.md — Stand nicht eindeutig"
    befunde=$((befunde + 1))
    continue
  fi
  zeile="$(grep '^\*\*Stand:\*\*' "$d/state.md" || true)"
  wort="${zeile#\*\*Stand:\*\*}"
  read -r wort _ <<<"$wort" || true
  wort="${wort%%[.,:;]}"
  case "$wort" in
    verkörpert|geplant|gestrichen) ;;
    *)
      echo "register-ausgang: $name: $belege Belege (evidence/*.md), Stand '${wort:-<keine Stand-Zeile>}' — ueber der 3x-Schwelle ohne Ausgang"
      befunde=$((befunde + 1))
      ;;
  esac
done

if [ "$eintraege" -eq 0 ]; then
  echo "register-ausgang: kein Eintrag unter '$root/BEO-*/*/' — leerer Pruefbereich, nichts geprueft" >&2
  exit 2
fi

echo "register-ausgang: $eintraege Eintraege, $ueber ueber der Schwelle, $befunde Befund(e)"
if [ "$befunde" -gt 0 ]; then
  echo "  -> den Ausgang weist der Lese-Schritt zu ($root/README.md); eine Ausnahmeliste gibt es nicht."
  exit 1
fi

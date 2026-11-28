#!/usr/bin/env bash
# full-smoke-skip — die hermetische Klassifikation des E2E-Skip-Griffs (ADR-0113
# Festlegung 3, Teilsupersede der Festlegung 4 von ADR-0111): liest die sieben
# committeten Stempel-Dateien .harness/state/full-smoke-passed-<variante>.key und
# beurteilt je deren `mengen-hash`-Feld gegen den frisch gerechneten Wert des
# Satzerzeugers. SKIP nur bei voller Deckung aller sieben; je Variante fehlend,
# unformal, fremd oder Satzerzeuger-Zweifel faellt auf den vollen Lauf zurueck
# (fail-closed, MR-017).
#
# DIE STEMPKLASSE (ADR-0113 Festlegung 1): je Datei zwei Zeilen — `variante <name>`
# (Form- und Selbst-Bindung: der Name der Datei wird gegen diese Zeile gelesen; ein
# fremdes Feld, eine falsche Zeile, ein Datei-Name ohne Zeile ist unformal) und
# `mengen-hash <64-hex>` (der Hash der Vorlagen-Menge der Variante — der Feld-Name
# nennt den Umfang; ein baum-hash-Haette ihn gefaelscht). Der Konsum liest allein
# das mengen-hash-Feld gegen die Frisch-Rechnung des Satzerzeugers
# (full-smoke-varianten.sh, Modus `alle`) — derselbe Massstab wie der Schreiber
# (ADR-0113 Festlegung 2: kein zweiter Massstab, LH-QA-02); ein E2E-Skip konserviert
# das Runner-Verdikt des Stempel-Laufs ueber genau den Vorlagen-Mengen, ueber die
# der Lauf fuhr. Kein Commit-SHA-Feld (Festlegung 3 von ADR-0111: zirkulaer), kein
# Datumsfeld (die Chronik traegt git).
#
# DER LAUFPFAD DES GRIFFS liegt in harness/tools/full-smoke.sh (Umgebung
# FULL_SMOKE_SKIP_KONSULT=1, gesetzt nur vom push-auf-main-Job der CI,
# ADR-0111 Festlegung 2 unverändert; am Host bleibt sie ungesetzt und der Lauf
# faehrt voll — er ist der Schreiber des Stempels). Dieses Skript traegt die reine
# Entscheidung: ein zweiter Massstab entsteht hier nicht.
#
# FORM: `--entscheide [<wurzel>]`
#   Exit 0 (mit SKIP-Meldung): alle sieben Stempel decken die Mengen — SKIP erlaubt.
#   Exit 1: voller Lauf (Stempel fehlt, Feld fehlt/unformal/fremd, Variante-Zeile
#           passt nicht zum Datei-Namen, oder die Satzerzeuger-Rechnung zweifelt).
#   Exit 2: Aufruf-Form.
# Hermetisch getestet ueber test/full-smoke-varianten-keys.bats (Fixtures ueber
# --wurzel, ADR-0113 Festlegung 6).
set -euo pipefail

# der Satzerzeuger liegt neben dem Konsum — die Wurzel-Aufloesung gilt ihm gleich
SATZERZEUGER="$(cd "$(dirname "$0")" && pwd)/full-smoke-varianten.sh"

# die Zwei-Zeilen-Form eines mengen-hash-Werts: 64 Hex — die Form der
# Satzerzeuger-Ausgabe; alles andere ist Parser-Zweifel (MR-017).
ist_hashform() {
  [[ "$1" =~ ^[0-9a-f]{64}$ ]]
}

skip_meldung() {
  printf 'full-smoke-skip: SKIP — die sieben committeten E2E-Stempel decken ihre Vorlagen-Mengen (ADR-0113 Festlegung 3): %s.\n' "$1"
  printf 'full-smoke-skip: Rest, den kein mengen-abgeleiteter Schluessel deckt (ADR-0113 Festlegung 3): die Verfuegbarkeit des Traeger-Releases (SHA256SUMS, Asset des gepinnten Tags), die Registry- und Netz-Zustaende und die Runner-Fassung des CI-Laeufers — der E2E-Skip konserviert das Runner-Verdikt des Stempel-Laufs.\n'
}

# entschluessele <wurzel> <zeile "variante hash"> — liest den Stempel der einen
# Variante, waehlt die mengen-hash-Zeile, beurteilt die Frisch-Rechnung dagegen.
# Ein anderes Feld traegt die Entscheidung nicht; die variante-Zeile ist Form- und
# Selbst-Bindung (sie passt zum Datei-Namen oder der Stempel ist unformal).
entschluessele() {
  local wurzel="$1" stempelzeile="$2" stempel zeile feld name="" hash=""
  local v frisch
  v="${stempelzeile%% *}"
  frisch="${stempelzeile##* }"
  # genau zwei Felder: "<v> <frisch>" — die Form des Modus `alle`
  if [ -z "$v" ] || [ "$frisch" != "${stempelzeile#* }" ]; then return 1; fi
  ist_hashform "$frisch" || return 1
  stempel="$wurzel/.harness/state/full-smoke-passed-${v}.key"
  if [ ! -f "$stempel" ]; then return 1; fi
  while IFS= read -r zeile || [ -n "$zeile" ]; do
    [ -n "$zeile" ] || continue
    feld="${zeile%% *}"
    case "$feld" in
      variante)
        [ -z "$name" ] || return 1
        name="${zeile#variante }"
        [ -n "$name" ] || return 1
        ;;
      mengen-hash)
        [ -z "$hash" ] || return 1
        hash="${zeile#mengen-hash }"
        [ -n "$hash" ] || return 1
        ;;
      *) return 1 ;;
    esac
  done <"$stempel"
  [ "$name" = "$v" ] || return 1
  ist_hashform "$hash" || return 1
  [ "$hash" = "$frisch" ] || return 1
  return 0
}

if [ "${1:-}" = "--entscheide" ]; then
  shift
  if [ "$#" -gt 1 ]; then
    echo "full-smoke-skip: --entscheide nimmt hoechstens die Wurzel" >&2
    exit 2
  fi
  wurzel="$1"
  if [ -z "$wurzel" ]; then
    if wurzel="$(git rev-parse --show-toplevel 2>/dev/null)"; then :; else wurzel="$PWD"; fi
  fi
  if [ ! -f "$SATZERZEUGER" ]; then
    echo "full-smoke-skip: der Satzerzeuger fehlt ($SATZERZEUGER) — voller Lauf" >&2
    exit 1
  fi
  frische="$(bash "$SATZERZEUGER" --wurzel "$wurzel" alle)" || {
    echo "full-smoke-skip: die Satzerzeuger-Rechnung zweifelt — voller Lauf (fail-closed, MR-017)" >&2
    exit 1
  }
  namen=""
  zeilen=0
  while IFS= read -r stempelzeile; do
    [ -n "$stempelzeile" ] || continue
    zeilen=$((zeilen + 1))
    entschluessele "$wurzel" "$stempelzeile" || exit 1
    namen="$namen ${stempelzeile%% *}"
  done <<<"$frische"
  if [ "$zeilen" -ne 7 ]; then
    echo "full-smoke-skip: die Satzerzeuger-Ernte traegt $zeilen Varianten, die Stempel-Klasse sieben — voller Lauf (fail-closed, MR-017)" >&2
    exit 1
  fi
  skip_meldung "${namen# }"
  exit 0
fi
echo "full-smoke-skip: Aufruf-Form — --entscheide [<wurzel>]" >&2
exit 2

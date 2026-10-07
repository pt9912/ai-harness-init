#!/usr/bin/env bash
# full-smoke-ausgang.sh — ordnet einen FEHLGESCHLAGENEN Abschnitt von
# harness/tools/full-smoke.sh einem von zwei Ausgaengen zu und schreibt ihn in die
# Ausgabe des Laufs:
#
#   LEITUNG — eine ausgehende Anfrage nach einem gepinnten Artefakt wurde nicht mit
#             2xx beantwortet. Der Pruefgegenstand wurde an dieser Stelle nicht
#             erreicht.
#   BAUM    — keine der gefuehrten Formen einer solchen Anfrage steht in den
#             gelesenen Zeilen. Der Fehlschlag wird dem geprueften Baum zugerechnet.
#
# WOZU: der Lauf stellt je Durchgang Dutzende Anfragen an fremde Registries und macht
# jede einzelne zur Bedingung seines Gruens. Beide Ausgaenge enden mit demselben
# Exit-Code; die Unterscheidung liegt allein in dieser Ausgabe.
#
# DER AUSGANG STEHT IN DER AUSGABE UND NICHT IM EXIT-CODE, und das ist eine Setzung:
# ein eigener Exit-Code fuer LEITUNG laedt dazu ein, den Lauf in diesem Fall
# durchzuwinken. Das waere die Schwellen-Senkung, die AGENTS.md 3.5 an ein ADR bindet.
# Dieses Skript endet mit 0, sobald es eingeordnet hat — rot bleibt der Aufrufer.
#
# WAS DER BAUM-AUSGANG NICHT SAGT: dass die Ursache im Baum LIEGT. Gemessen ist die
# ABWESENHEIT der unten gefuehrten Muster in den gelesenen Zeilen, nicht die Ursache.
# Deshalb lautet der Satz "wird zugerechnet" und nicht "ist".
#
# ZAHN: test/full-smoke-ausgang.bats faehrt beide Ausgaenge ueber Ausschnitten echter
# Laeufe; test/mutations/187 nimmt die Muster weg, test/mutations/188 macht LEITUNG
# bedingungslos, test/mutations/189 stellt im vollen Lauf einen nicht aufloesbaren
# Tag her. Muster (5): test/mutations/551 nimmt es weg, 552 weitet es auf jeden
# curl-Fehler, 553 stellt im vollen Lauf einen nicht veroeffentlichten Release-Tag her.
set -euo pipefail

# JEDES MUSTER STEHT NEBEN DEM LAUF, AN DEM ES GEMESSEN WURDE — ein Muster ohne
# gemessenen Treffer waere eine Vermutung ueber fremden Text.
#
# (1) BuildKit nennt im Fehler-Kontextblock den Schritt, an dem der Bau brach. Ist das
#     ein Aufloesungs-Schritt, war der Fehlschlag eine Anfrage an eine Registry.
#     Zweimal gemessen, mit verschiedenen Antwortcodes: CI-Job 97824094857 vom
#     2026-08-25 (502 auf golang:1.27.0) und lokal ueber
#     "make full-smoke GO_VERSION=9.99.9-gibt-es-nicht" (404 auf den nicht vergebenen
#     Tag). Das 6700-Zeilen-Protokoll des CI-Laufs traegt genau zwei Kontextblock-
#     Zeilen, beide dieser Form: "grep -cE '(^|[[:space:]])> ' " -> 2.
# (2) Der Resolver-Text von BuildKit, im selben CI-Job viermal gemessen. Das
#     Methoden-Token ist dort HEAD; welche Methoden sonst vorkommen, ist nicht
#     gemessen — deshalb eine Zeichenklasse und keine Liste.
# (3) Die Antwort des Docker-Daemons auf eine Registry-Anfrage beim Start eines
#     Containers. Zweimal gemessen ueber
#     "make ci-lint ACTIONLINT_IMAGE=ghcr.io/pt9912/gibt-es-diesen-namen-nicht:v0"
#     (Head, denied) und ueber einen nicht aufloesbaren Host (Get, no such host).
# (4) Derselbe Weg, wenn Repository und Host stimmen und nur der Tag fehlt. Gemessen
#     ueber "make ci-lint ACTIONLINT_IMAGE=rhysd/actionlint:gibt-es-diesen-tag-nicht".
# (5) Die Antwort von curl auf einen nicht mit 2xx beantworteten Abruf eines
#     Release-Assets (harness/tools/traeger-fetch.sh, Pruefsummen und Asset, beide
#     "curl -fsSL"). Klasse "Release-Asset nicht abrufbar". Gemessen in den CI-Jobs
#     112691251599, 112729405107 und 112925525011, jeweils an der Stufe
#     "make traeger-fetch im frischen Klon" mit
#     "curl: (22) The requested URL returned error: 404".
#     GRENZE: der Text trennt ein noch nicht veroeffentlichtes Release weder von einem
#     falsch gesetzten Pin noch von einem falsch gebildeten Asset-Namen im
#     Fetch-Skript selbst (Variable "asset", aus Plattform und Architektur gebildet und
#     in "url" eingesetzt) — alle drei sind eine nicht mit 2xx beantwortete Anfrage,
#     dieselbe Lesart wie (4) fuer einen nicht vergebenen Bild-Tag. Der dritte ist ein
#     Defekt des geprueften Baums und steht trotzdem als LEITUNG da; rot bleibt der
#     Lauf in jedem der drei Faelle. Die Klasse nennt den Weg,
#     keine Ursache. Gefuehrt ist allein der Exit-Code 22 (--fail); jeder andere
#     curl-Fehler, etwa (23) beim Schreiben am Ziel, faellt in den BAUM-Ausgang.
#
# WAS DIESE MUSTER NICHT SEHEN — die Grenze steht hier, weil sie sonst nur im Kopf des
# Lesenden stuende:
#   - Paketquellen der C++-Kette (archive.ubuntu.com, security.ubuntu.com). Ein
#     apt-Paket ist kein gepinntes Artefakt; sein Ausfall faellt in den BAUM-Ausgang.
#   - Ein Schicht-Download, der nach erfolgreicher Aufloesung bricht: dort nennt der
#     Kontextblock die FROM-Stufe statt der Aufloesung. Nicht gemessen, nicht gefuehrt.
#   - Jede Formulierung, die die Bau-Werkzeuge kuenftig waehlen. Aendert sie sich,
#     faellt die Einordnung auf BAUM zurueck: rot bleibt rot, die Aussage wird
#     unschaerfer, nie andersherum.
MUSTER=(
	'(^|[[:space:]])> (\[internal\] load metadata for|resolve image config for )'
	'unexpected status from [A-Z]+ request to https?://'
	'Error response from daemon: (Head|Get) "https?://'
	'Error response from daemon: manifest for .* not found'
	'curl: \(22\) The requested URL returned error: [0-9]+'
)
# KLASSE[i] gehoert zu MUSTER[i] und steht in der Beleg-Zeile; leer heisst: das Muster
# fuehrt keinen eigenen Klassennamen.
KLASSE=(
	''
	''
	''
	''
	'Release-Asset nicht abrufbar'
)

if [ "$#" -ne 1 ] || [ -z "$1" ]; then
	echo "full-smoke-ausgang.sh: genau ein Argument erwartet (die Kennung des Abschnitts); die Ausgabe des Abschnitts kommt auf stdin." >&2
	exit 2
fi
kennung="$1"

ausgabe="$(cat)"
# grep -c '' zaehlt die Zeilen ohne zweiten Prozess. Der Here-String hat keinen
# Producer, ein frueh schliessender Leser kann hier also kein EPIPE ausloesen.
gelesen="$(grep -c '' <<<"$ausgabe" || true)"

# Jeder Treffer wird mit seiner Muster-Nummer gefuehrt: die Nummer sagt, WELCHE der
# gemessenen Formen zugeschlagen hat, und macht den Ausgang ohne Blick in dieses
# Skript nachvollziehbar.
treffer=""
nummer=0
for muster in "${MUSTER[@]}"; do
	nummer=$((nummer + 1))
	zeile="$(grep -m1 -E -- "$muster" <<<"$ausgabe" || true)"
	if [ -n "$zeile" ]; then
		treffer="$treffer$nummer|$zeile"$'\n'
	fi
done

if [ -n "$treffer" ]; then
	echo "full-smoke: FEHLER — AUSGANG LEITUNG: $kennung. Eine ausgehende Anfrage nach einem gepinnten Artefakt wurde nicht mit 2xx beantwortet; der Pruefgegenstand wurde an dieser Stelle nicht erreicht. Der Lauf bleibt rot."
	while IFS='|' read -r nr rest; do
		[ -n "$nr" ] || continue
		klasse="${KLASSE[$((nr - 1))]:-}"
		if [ -n "$klasse" ]; then
			echo "full-smoke:   Beleg (Muster $nr von ${#MUSTER[@]}, Klasse: $klasse): $rest"
		else
			echo "full-smoke:   Beleg (Muster $nr von ${#MUSTER[@]}): $rest"
		fi
	done <<<"$treffer"
	exit 0
fi

echo "full-smoke: FEHLER — AUSGANG BAUM: $kennung. Keine der ${#MUSTER[@]} gefuehrten Formen einer nicht mit 2xx beantworteten Anfrage nach einem gepinnten Artefakt steht in den $gelesen gelesenen Zeilen; der Fehlschlag wird dem geprueften Baum zugerechnet."

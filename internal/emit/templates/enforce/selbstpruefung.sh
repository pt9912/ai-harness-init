#!/usr/bin/env bash
# tools/harness/selbstpruefung.sh — Selbstpruefung der emittierten
# Durchsetzungsschicht, emittiert von ai-harness-init. EIN KOMMANDO, KEIN GATE.
#
# WAS SIE BELEGT. Dieses Repo klont sich selbst in ein Wegwerf-Verzeichnis,
# stellt fest, dass der frische Klon KEINEN core.hooksPath traegt, aktiviert
# dort den Traeger der Commit-Kennung und faehrt danach ZWEI Commit-Versuche:
# einer OHNE Kennung faellt und entsteht nicht, einer MIT Kennung geht durch.
# Zuletzt laeuft das Gate-Kommando im Klon. BEIDE AUSGAENGE STEHEN IN EINEM
# LAUF — ein Lauf, der nur den durchgelassenen Commit beobachtet, belegt
# nicht, dass der Traeger ueberhaupt etwas aufhaelt.
#
# WARUM EIN KLON UND NICHT DIESES ARBEITSVERZEICHNIS. Die Aktivierung ist
# lokale Konfiguration (core.hooksPath) und reist nicht mit dem Klon; genau
# dieser Zustand ist der Pruefgegenstand. Und die zwei Commit-Versuche
# schreiben Historie — im Klon ist sie nach dem Lauf weg.
#
# DREI MARKER, JE MIT BELEGUNG. Sie sind Variablen, keine Platzhalter zum
# Suchen-und-Ersetzen: ein erneuter Lauf des Werkzeugs schreibt diese Datei
# kanonisch neu, und eine von Hand editierte Fassung waere danach wieder die
# ausgelieferte. Gesetzt werden sie ueber die Umgebung oder ueber das Fragment
# harness/mk/selbstpruefung.mk (make selbstpruefung SELBSTPRUEFUNG_GATE=…).
# Der Lauf nennt in seiner ersten Zeile die Werte, mit denen er faehrt.
#
# DIE GRENZE. Geprueft sind der Traeger und die zwei Commit-Ausgaenge. NICHT
# geprueft ist, ob der Traeger jeden Commit-Pfad erreicht: `git commit
# --no-verify` umgeht ihn, Commits aus Repo-Werkzeugen tragen ihre eigenen
# Messages, und Aufrufformen ausserhalb der aktivierten Traeger-Form bleiben
# ausserhalb der Zusage. Geprueft ist ferner die ANWESENHEIT einer Kennung in
# der Message, nicht ihre Wahrheit. Die Kennung der durchgelassenen Message
# unten stammt aus der Menge, die die Pruefung in ihrer Zeile `patterns=`
# fuehrt; wer jene Menge aendert, aendert diese Zeile mit.
#
# VORAUSSETZUNG. Ein git-Repo mit mindestens einem Commit. Der Klon traegt den
# Stand von HEAD — nicht committete Aenderungen des Arbeitsverzeichnisses sind
# darin nicht enthalten. Die Identitaet der zwei Commit-Versuche bringt der
# Lauf selbst mit (git -c user.email/user.name), damit die Pruefung auch auf
# einem Rechner ohne konfigurierte Identitaet laeuft.
#
# ABHAENGIGKEIT. git, make und coreutils. Kein Netz, kein Paketmanager, kein
# zweites Bild — was das Gate-Kommando seinerseits braucht, bringt es selbst
# mit.
set -euo pipefail

# Der Traeger, den der Klon fuehrt und den der Aktivierungsschritt in Betrieb
# nimmt. Der Name gehoert git, das Verzeichnis dem Repo.
SELBSTPRUEFUNG_TRAEGER="${SELBSTPRUEFUNG_TRAEGER:-.githooks/commit-msg}"
# Der eine Schritt zwischen liegendem Traeger und wirksamem Traeger.
SELBSTPRUEFUNG_AKTIVIERUNG="${SELBSTPRUEFUNG_AKTIVIERUNG:-make hooks-install}"
# Das Kommando, das im Klon gruen laufen muss. Ein Ziel mit anderem Bau- oder
# Sprachmodell setzt hier seines.
SELBSTPRUEFUNG_GATE="${SELBSTPRUEFUNG_GATE:-make gates}"

fehler() {
	echo "selbstpruefung: FEHLER — $1" >&2
	exit 1
}

command -v git >/dev/null 2>&1 || fehler "git liegt nicht im Pfad — ohne git gibt es keinen Klon, auf dem ein Traeger etwas aufhalten koennte."

quelle="$(git rev-parse --show-toplevel 2>/dev/null)" || fehler "dieses Verzeichnis liegt in keinem git-Repo — die Pruefung klont das Repo, in dem sie laeuft."
git -C "$quelle" rev-parse --verify --quiet 'HEAD^{commit}' >/dev/null 2>&1 ||
	fehler "$quelle traegt keinen Commit — ein Klon haette keinen Baum, auf dem ein Commit-Versuch etwas bedeutete. Ein erster Commit macht die Pruefung fahrbar."

echo "selbstpruefung: Marker — Traeger=[$SELBSTPRUEFUNG_TRAEGER] Aktivierung=[$SELBSTPRUEFUNG_AKTIVIERUNG] Gate=[$SELBSTPRUEFUNG_GATE]"
echo "selbstpruefung: Quelle=[$quelle] (der Klon traegt den Stand von HEAD)"

arbeit="$(mktemp -d)"
trap 'rm -rf "$arbeit"' EXIT
# mktemp -d liefert 0700. Laeuft das Gate-Kommando in einem Container als
# Nicht-Root, kann er einen 0700-Pfad nicht traversieren.
chmod 755 "$arbeit"
klon="$arbeit/klon"

# `file://` ist Pflicht: ueber einen blossen Pfad legt git einen Klon mit
# geteilten Objekten an, und der haengt am Quell-Repo statt fuer sich zu stehen.
git clone -q "file://$quelle" "$klon" || fehler "der Klon von $quelle ist nicht entstanden."
chmod 755 "$klon"

# (1) DER FRISCHE KLON IST UNGEPRUEFT. Gelesen wird der Wert aus git, nicht
# eine Meldung: `config --get` endet ohne Ausgabe und mit Exit 1, wo nichts
# gesetzt ist.
vorher_hooks="$(git -C "$klon" config --get core.hooksPath || true)"
if [ -n "$vorher_hooks" ]; then
	fehler "der frische Klon traegt bereits core.hooksPath=$vorher_hooks — dann misst der Lauf nicht, was die Aktivierung bewirkt."
fi
echo "selbstpruefung: der frische Klon traegt keinen core.hooksPath — der Traeger reist mit, seine Aktivierung nicht."

if [ ! -f "$klon/$SELBSTPRUEFUNG_TRAEGER" ]; then
	fehler "im Klon liegt kein Traeger unter [$SELBSTPRUEFUNG_TRAEGER] — er ist entweder nicht committet oder liegt woanders; der Marker SELBSTPRUEFUNG_TRAEGER nennt den Pfad."
fi

# (2) DIE AKTIVIERUNG. Gelesen wird der Wert, den git danach zurueckgibt.
akt_out=""
if ! akt_out="$(cd "$klon" && bash -c "$SELBSTPRUEFUNG_AKTIVIERUNG" 2>&1)"; then
	printf '%s\n' "$akt_out" >&2
	fehler "der Aktivierungsschritt [$SELBSTPRUEFUNG_AKTIVIERUNG] endet nicht mit Exit 0 — der Traeger ist im Klon nicht in Betrieb zu nehmen."
fi
printf '%s\n' "$akt_out" | sed 's/^/selbstpruefung:   /'
nachher_hooks="$(git -C "$klon" config --get core.hooksPath || true)"
if [ -z "$nachher_hooks" ]; then
	fehler "nach [$SELBSTPRUEFUNG_AKTIVIERUNG] ist core.hooksPath im Klon weiter leer — der Schritt meldet Erfolg, ohne einen zu haben."
fi
echo "selbstpruefung: aktiviert — core.hooksPath=$nachher_hooks"

# (3) DIE ZWEI COMMIT-AUSGAENGE, in einem Lauf. `--allow-empty` haelt jeden
# Versuch ohne Baum-Aenderung; gelesen werden Exit-Code UND die Lage von HEAD,
# denn eine Meldung allein belegt keinen Abbruch.
vorher_head="$(git -C "$klon" rev-parse HEAD)"
for fall in rot gruen; do
	case "$fall" in
	rot) msg="Selbstpruefung ohne Kennung" ;;
	gruen) msg="Selbstpruefung mit Kennung LH-FA-01" ;;
	*) fehler "unbekannter Fall [$fall]." ;;
	esac
	out=""
	rc=0
	out="$(git -C "$klon" -c user.email=selbstpruefung@example.invalid -c user.name=selbstpruefung \
		commit -q --allow-empty -m "$msg" 2>&1)" || rc=$?
	if [ "$fall" = rot ]; then
		if [ "$rc" -eq 0 ]; then
			fehler "der Commit '$msg' geht durch — eine Message ohne Kennung faerbt den Traeger nicht rot; das Ziel hat dann keine Durchsetzung, sondern eine Behauptung."
		fi
		nun_head="$(git -C "$klon" rev-parse HEAD)"
		if [ "$nun_head" != "$vorher_head" ]; then
			fehler "der Traeger meldet den Abbruch, der Commit ist aber entstanden (HEAD bewegt sich von $vorher_head nach $nun_head)."
		fi
		echo "selbstpruefung: ROT — ein Commit OHNE Kennung faellt am Traeger (Exit $rc) und HEAD steht unveraendert. Meldung des Traegers:"
		printf '%s\n' "$out" | sed -n '1,3p' | sed 's/^/selbstpruefung:   /'
	else
		if [ "$rc" -ne 0 ]; then
			printf '%s\n' "$out" >&2
			fehler "der Commit '$msg' faellt am Traeger (Exit $rc) — erwartet war ein Durchgang; der Traeger haelt dann auch auf, was er durchlassen soll."
		fi
		betreff="$(git -C "$klon" log -1 --format=%s)"
		if [ "$betreff" != "$msg" ]; then
			fehler "der Commit '$msg' meldet Erfolg, HEAD traegt aber '$betreff' — der Durchgang ist nicht belegt."
		fi
		echo "selbstpruefung: GRUEN — ein Commit MIT Kennung geht durch, HEAD traegt: $betreff"
	fi
done

# (4) DAS GATE-KOMMANDO IM KLON. Es laeuft zuletzt, weil die Schritte davor
# Historie schreiben und der Klon danach wegfaellt.
gate_rc=0
gate_out="$(cd "$klon" && bash -c "$SELBSTPRUEFUNG_GATE" 2>&1)" || gate_rc=$?
if [ "$gate_rc" -ne 0 ]; then
	printf '%s\n' "$gate_out" >&2
	fehler "[$SELBSTPRUEFUNG_GATE] im Klon endet mit Exit $gate_rc — der Klon traegt den Stand von HEAD, und der ist damit nicht gruen."
fi
# Die letzte Zeile des Gate-Laufs steht mit da: sie zeigt, WELCHES Kommando lief.
# Ohne sie waere von aussen nicht zu unterscheiden, ob der gesetzte Marker den Lauf
# gelenkt hat oder die Belegung.
echo "selbstpruefung: GATE — [$SELBSTPRUEFUNG_GATE] im Klon ist Exit 0. Letzte Zeile:"
printf '%s\n' "$gate_out" | sed '/^[[:space:]]*$/d' | tail -n 1 | sed 's/^/selbstpruefung:   /'
echo "selbstpruefung: OK — der Traeger [$SELBSTPRUEFUNG_TRAEGER] reist mit dem Klon, seine Aktivierung nicht; [$SELBSTPRUEFUNG_AKTIVIERUNG] setzt core.hooksPath, danach faellt ein Commit OHNE Kennung und geht einer MIT Kennung durch, und [$SELBSTPRUEFUNG_GATE] laeuft im Klon gruen. Nicht geprueft: ob der Traeger jeden Commit-Pfad erreicht (--no-verify, Werkzeug-Commits, andere Aufrufformen)."

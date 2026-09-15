#!/usr/bin/env bash
# full-smoke.sh — Voll-E2E-Smoke (slice-024, LH-FA-01 Happy-Path + LH-QA-01).
#
# Bootstrap in ein tmp-Repo, dann dort `make gates` — der EINE Einstiegspunkt, den
# ein Adopter faehrt. Das ist der Beweis, den welle-01 aufschob und welle-02
# weitergab: ein frisch gebootstrapptes Zielrepo faehrt `make gates` out-of-the-box
# gruen, ohne Nacharbeit.
#
# Abgrenzung zum Tier-2 `make smoke` (slice-002): jener prueft die Bootstrap-SCHRITTE
# einzeln (Templates emittiert, docs-check-Config valide + 0 Befunde, Go-Gates
# getrennt via `-f d-check.mk` bzw. `lint build test`). DIESER faehrt den
# ZUSAMMENGEFUEHRTEN `make -j gates` (slice-034: das Aggregator-Makefile bindet die
# Gate-Fragmente harness/mk/*.mk ein — baseline/doc-gate/enforce + go —, die Checks
# akkumulieren in GATE_CHECKS und record-gates stempelt zuletzt via Ordnungskante)
# — die Sicht des echten Nutzers, die `make smoke` bewusst NICHT nimmt.
#
# Host-Docker + ggf. Netz-Pull -> NICHT in `make gates` (offline-schlank, LH-QA-01);
# gehoert an DoD-Verify/CI/Wellen-Closure. Logik in harness/tools/ (shell-lint deckt sie).
set -euo pipefail

HIER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# einordnen sagt fuer einen fehlgeschlagenen Abschnitt, welcher der zwei Ausgaenge
# vorliegt: eine ausgehende Anfrage nach einem gepinnten Artefakt blieb unbeantwortet
# (LEITUNG) oder der gepruefte Baum ist rot (BAUM). Der Aufruf steht NEBEN der
# FEHLER-Zeile des Abschnitts, nicht an ihrer Stelle: jene nennt den
# Pruefgegenstand, diese die Herkunft des Rots. Der Exit-Code aendert sich durch die
# Einordnung nicht.
#
# ABDECKUNG — ein KRITERIUM statt einer Aufzaehlung: eingeordnet ist jeder Abschnitt,
# der ein Bild anfordern kann. Das ist die Eigenschaft, um die es geht; eine Liste von
# Fundstellen veraltet mit der naechsten eingefuegten Stufe, das Kriterium nicht.
#
# Die Menge, ueber der es gilt, ist mechanisch abgegrenzt — ein Abschnitt fuehrt seinen
# eigenen Exit-Code:
#   (A) grep -cE '\|\| [a-z_0-9]+=\$\?$' harness/tools/full-smoke.sh
# Drei Formen darin fordern KEIN Bild an, und zwar nachpruefbar: der Trockenlauf (make -n
# fuehrt kein Rezept aus), make span-clean (sein Rezept im Ziel ist rm -rf plus echo) und
# der Hook-Wrapper (ein Shell-Skript, das das Host-Binaer startet und docker nicht nennt):
#   (B) … | grep -cE ' -n |span-clean|bash "\$wrapper"'
# Der Rest teilt sich in make-Stufen und Aufrufe des Werkzeugs:
#   (C) … | grep -c 'tmpbin/ai-harness-init'
# JEDE make-Stufe dieser Restmenge traegt eine Einordnung, dazu die zwei Werkzeug-Aufrufe,
# die als erste ein noch nicht lokal liegendes Bild anfordern (d-check beim ersten
# Bootstrap, a-check beim ersten --arch-Modul). Die Probe auf das Kriterium ist eine
# Gleichung und kein Nachzaehlen:
#   A - B - C  ==  grep -cE '^[[:space:]]*einordnen "' harness/tools/full-smoke.sh  -  2
#
# NICHT eingeordnet sind die uebrigen Werkzeug-Aufrufe. Sie koennen nur dieselben zwei
# Bilder anfordern — das Werkzeug hat genau einen Docker-Aufrufpunkt (printMK in
# internal/emit/emit.go, geteilt von d-check und a-check) —, und die liegen nach den zwei
# Erstbezuegen lokal. Sie laufen unter set -e und brechen ohne eigene Meldung ab.
#
# Die Muster, ihre Messung und ihre Grenzen stehen im Kopf des gerufenen Skripts.
einordnen() {
	bash "$HIER/full-smoke-ausgang.sh" "$1" <<<"$2" >&2
}

GO_VERSION="${GO_VERSION:-1.27.0}"
tmpbin="$(mktemp -d)"
# Elternverzeichnis der zwei Klone, die der Vorlauf-Waechter-Abschnitt derselben Quelle
# anlegt (flach und vollstaendig). chmod 755 aus demselben Grund wie beim tmprepo-Root
# unten: das d-check-Modul mountet sie read-only in einen Nicht-Root-Container.
tmpklon="$(mktemp -d)"
tmprepo="$(mktemp -d)"
tmprepo_doc="$(mktemp -d)"
tmprepo_hex="$(mktemp -d)"
tmprepo_cpphex="$(mktemp -d)"
cleanup() { rm -rf "$tmpbin" "$tmpklon" "$tmprepo" "$tmprepo_doc" "$tmprepo_hex" "$tmprepo_cpphex"; }
trap cleanup EXIT
chmod 755 "$tmpklon"
chmod 755 "$tmprepo_doc"
# Das Root-Modul-Ziel (slice-046) wird von a-check als read-only Mount gelesen — wie die
# anderen Ziele braucht es 0755 (ein echtes Adopter-Repo hat das).
chmod 755 "$tmprepo_hex"
# Auch das cpp-Root-Ziel (slice-054) wird von a-check read-only gemountet.
chmod 755 "$tmprepo_cpphex"
# mktemp -d liefert 0700; der d-check-Container laeuft als Nicht-Root und kann den
# 0700-Mount nicht traversieren. Ein echtes Adopter-Git-Repo hat 0755.
chmod 755 "$tmprepo"

# DIE ROLLEN-TYPEN LIEGEN IM ZIEL (LH-FA-10 / ADR-0022 Festlegung 3). Sechs Dateien
# unter .claude/agents/, je eine kanonische Rolle, und jede fuehrt ihren Rollen-Namen im
# Frontmatter — dieser Name ist der Vertrag zur Rollen-Achse: die Erfassung besetzt sie
# nur bei einer der sechs, jeder andere Wert ergibt ein leeres Feld.
#
# WOZU DIESE PRUEFUNG NEBEN DEM `make gates` DES ZIELS: jener Lauf scannt die Typ-Dateien
# mit (die emittierte .d-check.yml faehrt links/anchors ueber roots: ["."]) und faellt
# ueber einem toten relativen Verweis darin. Ueber einem LEEREN .claude/agents/ faellt er
# nicht — er bliebe gruen und pruefte nichts. Erst die Anwesenheit macht sein Gruen zur
# Aussage ueber die Typ-Dateien.
#
# KEINE EIGENE NAMENSLISTE: die erwarteten Rollen kommen aus der QUELLE dieses Repos
# (internal/emit/templates/agents/*.md), nicht aus einem hier gepflegten Literal. Ein
# Uebertragungsfehler, der eine Rolle auf dem Weg zum Ziel verliert, faellt damit auf —
# die Quelle fuehrt sie weiterhin, das Ziel nicht mehr. Ein leerer Fund unter der Quelle
# selbst (falscher Pfad, verschobenes Verzeichnis) ist ein eigener Fehler und kein
# stilles Durchlaufen ueber null Rollen.
#
# Aufgerufen fuer BEIDE Bootstrap-Varianten: die Rollen-Sequenz ist sprach-agnostisch,
# und ein Zahn in nur einer Variante belegte das nicht.
rollen_typen_im_ziel() {
	local repo="$1" label="$2" quelle role f n=0
	quelle="$HIER/../../internal/emit/templates/agents"
	shopt -s nullglob
	for f in "$quelle"/*.md; do
		role="$(basename "$f" .md)"
		n=$((n + 1))
		f="$repo/.claude/agents/$role.md"
		if [ ! -f "$f" ]; then
			echo "full-smoke: FEHLER — Rollen-Typ fehlt ($label): .claude/agents/$role.md" >&2
			exit 1
		fi
		if ! grep -qxF "name: $role" "$f"; then
			echo "full-smoke: FEHLER — Rollen-Typ ($label) ohne 'name: $role' im Frontmatter — die Rollen-Achse bliebe leer" >&2
			exit 1
		fi
	done
	shopt -u nullglob
	if [ "$n" -eq 0 ]; then
		echo "full-smoke: FEHLER — keine Rollen-Typ-Quellen unter $quelle gefunden (leerer Pruefbereich)" >&2
		exit 1
	fi
	echo "full-smoke: Rollen-Typen im Ziel ($label): $n kanonische Typen unter .claude/agents/, je mit ihrem Namen im Kopf."
}

# slice-098 (LH-FA-10 / ADR-0022 Festlegung 7 und 5(a)): DIE FELDLISTE LIEGT IM GEPRUEFTEN
# DOKU-BEREICH DES ZIELS UND FUEHRT IHRE GRENZEN STEHEND.
#
# Zwei Gegenstaende in einer Datei, und der zweite ist kein Anhang: die Tabelle sagt, WAS
# erfasst wird; die drei Saetze sagen, wie wenig darueber zugesagt ist. Sie gelten auch
# dann, wenn niemand eine Auswertung ruft — deshalb stehen sie im Dokument und nicht nur
# in deren Ausgabe.
#
# VOR dem Gate-Lauf aufgerufen, aus demselben Grund wie bei den Rollen-Typen: ueber einer
# FEHLENDEN Datei bliebe das `make gates` des Ziels gruen und pruefte nichts. Erst die
# Anwesenheit macht sein Gruen zur Aussage ueber dieses Dokument.
FELDLISTE_REL="harness/erfassung-feldliste.md"
feldliste_im_ziel() {
	local repo="$1" label="$2"
	local doc="$repo/$FELDLISTE_REL"
	if [ ! -f "$doc" ]; then
		echo "full-smoke: FEHLER — $label: die Feldliste liegt nicht im GEPRUEFTEN Doku-Bereich des Ziels (erwartet $FELDLISTE_REL). Dort liest das Doku-Gate des Ziels sie; unter .harness/** nimmt die emittierte .d-check.yml sie aus (slice-098)." >&2
		exit 1
	fi
	# Der Backtick steht in einer VARIABLEN: in einfachen Anfuehrungszeichen liest der
	# Shell-Lint ihn als beabsichtigte Kommando-Substitution, in doppelten waere er eine.
	# Die Umformulierung ist der Weg, den AGENTS.md §3.2 laesst — eine Inline-Suppression
	# nicht.
	local bt zeilen
	bt='`'
	zeilen="$(grep -cE "^[|] ${bt}[a-z0-9_]+${bt} [|] (Pflicht|Optional) [|]" "$doc" || true)"
	if [ "$zeilen" -lt 1 ]; then
		echo "full-smoke: FEHLER — $label: die Feldliste traegt keine einzige Feld-Zeile — eine Ueberschrift ohne Liste sagt nicht, was erfasst wird (slice-098)." >&2
		exit 1
	fi
	# Leerraum-normalisiert vergleichen: WO das Dokument umbricht, ist gleichgueltig; WAS
	# es sagt, nicht. Ohne die Normalisierung braeche jeder Zeilenumbruch mitten in einem
	# Satz den Vergleich, und der Waechter haenge an der Textbreite statt an der Aussage.
	local flach fehlend="" satz
	flach="$(tr -s '[:space:]' ' ' <"$doc")"
	for satz in "Über die Aufrufform des Agenten-Werkzeugs führt diese Ebene keinen Wächter" \
	            "Die Verbrauchs-Zähler kommen aus der Mechanik des Agenten-Werkzeugs nicht" \
	            "Über den Bestand ist nichts zugesagt"; do
		grep -qF -- "$satz" <<<"$flach" || fehlend="$fehlend [$satz]"
	done
	if [ -n "$fehlend" ]; then
		echo "full-smoke: FEHLER — $label: die Feldliste fuehrt eine Grenze nicht, die kein Sensor haelt:$fehlend (slice-098)." >&2
		exit 1
	fi
	echo "full-smoke: Feldliste im Ziel ($label): $FELDLISTE_REL mit $zeilen Feld-Zeilen und den drei stehenden Grenz-Saetzen."
}

# slice-098, die inhaltliche Haelfte: WAS DER TRAEGER SCHREIBT, STEHT AUCH IN DER LISTE.
# Gemessen wird gegen eine ECHTE Span-Zeile aus dem Ziel, nicht gegen eine zweite Liste im
# Skript — jedes Feld, das die Zeile fuehrt, braucht seine Tabellen-Zeile. Ein Feld, das
# erfasst wird und dort fehlt, ist genau die Drift, die ADR-0022 Festlegung 7 konstruktiv
# ausschliesst.
feldliste_deckt_die_zeile() {
	local repo="$1" label="$2" line="$3"
	local doc="$repo/$FELDLISTE_REL"
	local feld fehlend="" gemessen=0
	for feld in $(grep -oE '"[a-z0-9_]+":' <<<"$line" | tr -d '":' | sort -u); do
		gemessen=$((gemessen + 1))
		grep -qF -- "| \`$feld\` |" "$doc" || fehlend="$fehlend [$feld]"
	done
	if [ "$gemessen" -eq 0 ]; then
		echo "full-smoke: FEHLER — $label: aus der Span-Zeile des Ziels liess sich kein Feldname lesen — der Abgleich mit der Feldliste misst nichts (slice-098)." >&2
		exit 1
	fi
	if [ -n "$fehlend" ]; then
		echo "full-smoke: FEHLER — $label: der Traeger schreibt Felder, die seine Feldliste nicht fuehrt:$fehlend — das Ziel erfasst mehr, als es lesbar sagt (slice-098)." >&2
		exit 1
	fi
	echo "full-smoke: Feldliste deckt die Zeile ($label): alle $gemessen Feldnamen der geschriebenen Span-Zeile haben ihre Zeile in $FELDLISTE_REL."
}

echo "full-smoke: 1/3 natives Release-Binary auf den Host extrahieren (make artifact) ..."
# Die Ausgabe wird EINGEFANGEN und danach gedruckt, statt zu stroemen: nur eingefangen
# steht sie der Einordnung zur Verfuegung. Unter pipefail traegt der Zuweisungs-Exit
# den Exit der make-Stufe.
artefakt_rc=0
artefakt_out="$( make artifact DEST="$tmpbin" GO_VERSION="$GO_VERSION" 2>&1 )" || artefakt_rc=$?
printf '%s\n' "$artefakt_out"
if [ "$artefakt_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — make artifact ist NICHT Exit 0: das Release-Binary kam nicht auf den Host (Exit $artefakt_rc)." >&2
	einordnen "make artifact (Host-Bau und Extraktion des Release-Binaers)" "$artefakt_out"
	exit 1
fi

echo "full-smoke: 2/3 Bootstrap (--lang go --name full-smoke) in ein leeres tmp-Repo ..."
# ERSTER AUFRUF DES WERKZEUGS und damit die erste Anfrage nach dem d-check-Bild: das
# Werkzeug erzeugt das Doku-Gate-Fragment aus dessen --print-mk-Ausgabe. Auf einem
# frischen Laeufer liegt das Bild nicht lokal.
init_rc=0
init_out="$( cd "$tmprepo" && "$tmpbin/ai-harness-init" --lang go --name full-smoke 2>&1 )" || init_rc=$?
printf '%s\n' "$init_out"
if [ "$init_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — der Bootstrap (--lang go) ist NICHT Exit 0 (Exit $init_rc)." >&2
	einordnen "Bootstrap --lang go (das Werkzeug holt d-check fuer --print-mk)" "$init_out"
	exit 1
fi

# Vor dem Gate-Lauf, damit dessen Gruen eine Aussage ueber die Typ-Dateien ist (slice-097).
rollen_typen_im_ziel "$tmprepo" "--lang go"
# Aus demselben Grund vor dem Gate-Lauf: das Dokument liegt im geprueften Bereich (slice-098).
feldliste_im_ziel "$tmprepo" "--lang go"

# slice-031: ein echter Adopter bootstrappt IN sein git-Repo. Der Gate-Nachweis
# (record-gates -> working-tree-hash, jetzt letztes gates-Prerequisite) braucht
# git (rev-parse/ls-files). Kein Commit noetig — --others erfasst die untracked
# Bootstrap-Dateien; .harness/.gitignore haelt den Stempel aus dem Hash.
git init -q "$tmprepo"

echo "full-smoke: 3/3 im Ziel: make -j gates (der zusammengefuehrte Einstiegspunkt, Fragment-Assembly slice-034) ..."
gates_rc=0
gates_out="$( make -j -C "$tmprepo" gates 2>&1 )" || gates_rc=$?
printf '%s\n' "$gates_out"
if [ "$gates_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — make gates im emittierten Repo ist NICHT Exit 0 (LH-FA-01 Happy-Path verletzt)." >&2
	einordnen "make -j gates im Ziel (--lang go)" "$gates_out"
	exit 1
fi

# LH-QA-01: `make gates` muss die BEHAUPTETEN Gates WIRKLICH fahren, nicht still eine
# Teilmenge. Belege im Lauf-Output, dass ALLE Checks liefen: die drei Go-Gates
# (Dockerfile-Stages, per make-Recipe-Echo `--target <stage>`), das Doc-Gate (d-check
# druckt "… Datei(en) geprueft") UND baseline-verify (seit slice-034 verdrahtet, sein
# Erfolgs-Satz "Integritaet + Vollstaendigkeit"). Ein gruenes make gates ueber einer
# stillen Teilmenge waere ein halluziniertes Gate. Die Marker decken zugleich die
# Fragment-Assembly (slice-034): fehlte die Ordnungskante record-gates auf GATE_CHECKS,
# haengte gates nur an record-gates (ohne Prereqs) -> die Checks liefen GAR NICHT, alle
# Marker fehlten -> hier rot (nicht bloss Exit 0 pruefen). Die Marker stammen aus der
# Laufzeit bzw. dem Recipe-Echo, nicht aus einer statischen Behauptung.
#
# Marker-Grep per HERE-STRING (grep -qF <<<"$var"), NICHT `printf | grep -q`: unter
# `set -o pipefail` schliesst `grep -q` beim ersten Treffer die Pipe, `printf` bekommt
# EPIPE (Broken pipe), und pipefail propagiert dessen Nonzero -> der `|| missing`-Zweig
# feuert, OBWOHL der Marker gefunden wurde. Das schlaegt nur bei GROSSEM $var zu (printf
# schreibt noch, wenn grep frueh matcht) -> in CI beim langen apt-Log des C++-Bildes rot,
# lokal gruen (Race). Der Here-String hat keinen Producer-Prozess -> kein EPIPE (slice-039).
missing=""
for marker in "--target lint" "--target build" "--target test" "geprüft" "Integritaet + Vollstaendigkeit"; do
	grep -qF -- "$marker" <<<"$gates_out" || missing="$missing [$marker]"
done
if [ -n "$missing" ]; then
	echo "full-smoke: FEHLER — make gates lief gruen, aber ohne Beleg fuer:$missing — stilles Teilmengen-Gate? (LH-QA-01)" >&2
	exit 1
fi

# slice-031 (LH-FA-06/ADR-0006): der Gate-Nachweis-Kreis muss sich schliessen.
# `make gates` endet mit record-gates, das den Content-Hash des Working Tree
# stempelt. Beleg: (a) der Stempel existiert; (b) er == einer frischen
# working-tree-hash-Berechnung. (b) validiert ZUGLEICH .harness/.gitignore: fehlte
# der state/-Ignore, zaehlte der Stempel selbst in den Hash und (b) wiche ab — im
# Ziel blockte der Stop-Hook sich dann selbst. Ein blosses „Stempel da" waere zu
# schwach (der Selbst-Blockade-Bug erzeugt AUCH einen Stempel).
stamp_file="$tmprepo/.harness/state/gates-passed.diffsha"
if [ ! -f "$stamp_file" ]; then
	echo "full-smoke: FEHLER — record-gates schrieb keinen Gate-Nachweis-Stempel (slice-031)." >&2
	exit 1
fi
recomputed="$( cd "$tmprepo" && bash tools/harness/working-tree-hash.sh )"
if [ "$recomputed" != "$(cat "$stamp_file")" ]; then
	echo "full-smoke: FEHLER — Gate-Nachweis-Hash weicht vom Stempel ab: der Stop-Hook blockte sich" >&2
	echo "  selbst (fehlt/greift .harness/.gitignore nicht? zaehlt der Stempel in den Hash?) (slice-031)." >&2
	exit 1
fi

# --- Vorlauf-Waechter der zwei history-lesenden Targets --------------------------------
#
# WAS DER HAPPY PATH NICHT SIEHT: `make gates` faehrt `doc-immutable`/`doc-commits` NICHT —
# beide brauchen eine RANGE, ein gruener gates-Lauf im Ziel prueft den Waechter also nie
# (LH-QA-01: ein Gate ueber leerem Pruefbereich, das gruen meldet, behauptet mehr als es
# prueft). Gefahren wird er darum ausdruecklich, und in beiden Richtungen: der Abbruch
# ueber einer leeren Range UND der gruene Lauf daneben. Eine Richtung allein belegt nichts
# (AGENTS.md §3.6) — ein Waechter, der immer rot faerbt, bestuende die erste Haelfte.
#
# NUR HIER MESSBAR: die Kette Aggregator -> Fragment -> d-check.mk-Target -> abgelegtes
# Skript entsteht erst im gebootstrappten Ziel. Der Go-Test liest den TEXT des Fragments
# (internal/emit/emit_test.go), nicht seine Wirkung.
#
# KEIN EIGENER EXIT-CODE-ABSCHNITT fuer die git-Schritte unten: sie koennen kein Bild
# anfordern, und der Einordner deckt Registry-Ausfaelle. Ein Abschnitt, der ein Ziel mit
# `docker run` faehrt, traegt dagegen Einordnung UND Exit-Code — die Abdeckungs-Gleichung
# im Kopf zaehlt beide Seiten.

# waechter_bricht_ab faehrt ein bewachtes Target ueber einer Range, die ABBRECHEN MUSS, und
# liest den Grund. `exit != 0` genuegt nicht (AGENTS.md §3.6): die Meldung muss vom
# Vorlauf-Waechter kommen, und der Modul-Lauf darf nicht stattgefunden haben — er sitzt VOR
# ihm, nicht danach.
waechter_bricht_ab() {
	local repo="$1" ziel="$2" range="$3" erwartet="$4" kennung="$5"
	local out="" rc=0 grund="" flach
	out="$( make --no-print-directory -C "$repo" "$ziel" RANGE="$range" 2>&1 )" || rc=$?
	flach="$(tr -s '[:space:]' ' ' <<<"$out")"
	if [ "$rc" -eq 0 ]; then
		grund="make $ziel blieb ueber '$range' GRUEN (Exit 0)"
	elif ! grep -qF -- "$erwartet" <<<"$flach"; then
		grund="der Abbruch nennt '$erwartet' nicht (rot aus falschem Grund?)"
	elif grep -qF -- "Datei(en) geprüft" <<<"$flach"; then
		grund="der d-check-Lauf fand trotzdem statt — der Waechter steht NACH dem Modul-Lauf"
	fi
	if [ -n "$grund" ]; then
		echo "full-smoke: FEHLER — $kennung ($ziel, RANGE=$range): $grund. Ausgabe:" >&2
		printf '%s\n' "$out" >&2
		einordnen "make $ziel im Ziel ($kennung)" "$out"
		exit 1
	fi
	echo "full-smoke: Waechter greift ($kennung): make $ziel RANGE=$range bricht ab, ohne ein Modul zu fahren."
}

# blind_gruen_ohne_waechter <repo> <ziel> <kennung> faehrt ein bewachtes Target OHNE das
# Doc-Gate-Fragment — `-f d-check.mk` DIREKT, dieselbe Form wie `make smoke` — und erwartet
# ueber der leeren Range die Klasse, gegen die der Waechter steht: "0 Befund(e)", Exit 0.
# Gefahren werden BEIDE history-lesenden Targets; eine Haelfte ohne eigene Messung waere eine
# verlinkte Behauptung (AGENTS.md §3.6).
blind_gruen_ohne_waechter() {
	local repo="$1" ziel="$2" kennung="$3"
	local roh="" roh_rc=0 rohgrund="" rohflach=""
	roh="$( make --no-print-directory -C "$repo" -f d-check.mk "$ziel" RANGE=HEAD..HEAD 2>&1 )" || roh_rc=$?
	rohflach="$(tr -s '[:space:]' ' ' <<<"$roh")"
	if [ "$roh_rc" -ne 0 ]; then
		rohgrund="das Modul ohne den Waechter endet mit Exit $roh_rc statt mit 0"
	elif ! grep -qF -- '0 Befund(e)' <<<"$rohflach"; then
		rohgrund="das Modul meldet ueber der leeren Range nicht '0 Befund(e)' — der Anlass ist hier nicht reproduziert"
	fi
	if [ -n "$rohgrund" ]; then
		echo "full-smoke: FEHLER — $kennung (d-check.mk direkt, $ziel): $rohgrund. Ausgabe:" >&2
		printf '%s\n' "$roh" >&2
		einordnen "make -f d-check.mk $ziel im flachen Klon ($kennung)" "$roh"
		exit 1
	fi
	echo "full-smoke: OHNE den Waechter meldet dasselbe Modul ueber derselben leeren Range gruen ($ziel) — die Klasse 'blind und gruen', gegen die der Waechter steht:"
	grep -F -- '0 Befund(e)' <<<"$roh" | sed -n '1p' | sed 's/^/full-smoke:   /'
}

# vorbindung_ohne_zieldefinition <repo> <ziel> <kennung> erwartet den LAUTEN Abbruch ueber
# einem d-check.mk, in dem die Ziel-Definition fehlt — die Ziel-Zeile selbst ODER ihr Rezept:
# Exit != 0, die Meldung des Fragments, kein Modul-Lauf. Eine Vorbindung ueber einem Ziel
# ohne Rezept laesst allein den Waechter laufen (Exit 0); dagegen steht die fail-closed Zeile
# des Fragments.
vorbindung_ohne_zieldefinition() {
	local repo="$1" ziel="$2" kennung="$3"
	local out="" rc=0 flach="" grund=""
	out="$( make --no-print-directory -C "$repo" "$ziel" RANGE=HEAD~1..HEAD 2>&1 )" || rc=$?
	flach="$(tr -s '[:space:]' ' ' <<<"$out")"
	if [ "$rc" -eq 0 ]; then
		grund="make $ziel blieb ueber einem d-check.mk OHNE die Ziel-Definition GRUEN (Exit 0) — die Vorbindung hat dort kein Rezept"
	elif ! grep -qF -- "fuehrt '$ziel' nicht" <<<"$flach"; then
		grund="der Abbruch nennt die fehlende Ziel-Definition nicht (rot aus falschem Grund?)"
	elif grep -qF -- "Datei(en) geprüft" <<<"$flach"; then
		grund="der Modul-Lauf fand trotzdem statt"
	fi
	if [ -n "$grund" ]; then
		echo "full-smoke: FEHLER — $kennung (d-check.mk ohne Ziel-Definition, $ziel): $grund. Ausgabe:" >&2
		printf '%s\n' "$out" >&2
		einordnen "make $ziel ueber einem d-check.mk ohne Ziel-Definition ($kennung)" "$out"
		exit 1
	fi
	echo "full-smoke: Zieldefinition ($kennung): make $ziel bricht ueber einem d-check.mk ohne Ziel-Definition LAUT ab, ohne ein Modul zu fahren."
}

# vorbindung_mit_zieldefinition <repo> <ziel> <kennung> ist die gruene Haelfte derselben Sonde:
# derselbe Aufruf ueber dem UNVERFAELSCHTEN d-check.mk — Waechter greift, das Modul laeuft, Exit 0.
vorbindung_mit_zieldefinition() {
	local repo="$1" ziel="$2" kennung="$3"
	local out="" rc=0 flach="" grund=""
	out="$( make --no-print-directory -C "$repo" "$ziel" RANGE=HEAD~1..HEAD 2>&1 )" || rc=$?
	flach="$(tr -s '[:space:]' ' ' <<<"$out")"
	if [ "$rc" -ne 0 ]; then
		grund="derselbe Aufruf endet ueber dem unverfaelschten d-check.mk mit Exit $rc statt mit 0"
	elif ! grep -qF -- 'Datei(en) geprüft' <<<"$flach"; then
		grund="der Modul-Lauf fand nicht statt — das Gruen waere dann keines des Moduls"
	fi
	if [ -n "$grund" ]; then
		echo "full-smoke: FEHLER — $kennung (d-check.mk mit Ziel-Definition, $ziel): $grund. Ausgabe:" >&2
		printf '%s\n' "$out" >&2
		einordnen "make $ziel ueber dem unverfaelschten d-check.mk ($kennung)" "$out"
		exit 1
	fi
	echo "full-smoke: Zieldefinition ($kennung): derselbe Aufruf ueber dem unverfaelschten d-check.mk bleibt gruen ($ziel), der Modul-Lauf fand statt."
}

# vorbindung_ohne_probewerkzeug <repo> <ziel> <kennung> faehrt die Randlage derselben Sonde:
# die Ziel-Definition FEHLT und das Probe-Werkzeug (awk) ist nicht im PATH. Der unbekannte
# Ausgang darf nicht in den permissiven Zweig fallen — der Aufruf muss abbrechen.
vorbindung_ohne_probewerkzeug() {
	local repo="$1" ziel="$2" kennung="$3" mk
	local out="" rc=0 flach="" grund=""
	if ! mk="$(command -v make)"; then
		echo "full-smoke: FEHLER — $kennung: make ist nicht auffindbar." >&2
		exit 1
	fi
	out="$( env PATH=/nonexistent "$mk" --no-print-directory -C "$repo" -n "$ziel" RANGE=HEAD~1..HEAD 2>&1 )" || rc=$?
	flach="$(tr -s '[:space:]' ' ' <<<"$out")"
	# Der Trockenlauf fuehrt kein Rezept aus — die Entscheidung ist an der GEDRUCKTEN Kette
	# abgelesen: die Bindung druckt die Waechter-Zeile, der Abbruch seine Meldung.
	if grep -qF -- 'history-range-guard.sh' <<<"$flach"; then
		grund="der Aufruf waehlte trotz fehlenden Probe-Werkzeugs die Bindung — make -n druckt die Waechter-Zeile (Exit $rc)"
	elif ! grep -qF -- "fuehrt '$ziel' nicht" <<<"$flach"; then
		grund="der Aufruf nennt die fehlende Ziel-Definition nicht (rot aus falschem Grund?)"
	fi
	if [ -n "$grund" ]; then
		echo "full-smoke: FEHLER — $kennung (ohne Probe-Werkzeug im PATH, $ziel): $grund. Ausgabe:" >&2
		printf '%s\n' "$out" >&2
		exit 1
	fi
	echo "full-smoke: Zieldefinition ($kennung): ohne das Probe-Werkzeug bricht make $ziel LAUT ab, statt zu binden."
}

# vorbindung_gegen_die_kommandozeile <repo> <ziel> <kennung> faehrt denselben verfaelschten
# Baum mit DOC_GATE_ZIEL=da auf der KOMMANDOZEILE: die Entscheidung des Fragments bleibt, der
# Aufruf bricht ab. Ohne override setzt der Aufrufer die Zusage ausser Kraft.
vorbindung_gegen_die_kommandozeile() {
	local repo="$1" ziel="$2" kennung="$3"
	local out="" rc=0 flach="" grund=""
	out="$( make --no-print-directory -C "$repo" -n DOC_GATE_ZIEL=da "$ziel" RANGE=HEAD~1..HEAD 2>&1 )" || rc=$?
	flach="$(tr -s '[:space:]' ' ' <<<"$out")"
	if grep -qF -- 'history-range-guard.sh' <<<"$flach"; then
		grund="die Kommandozeile setzte die Entscheidung — make -n druckt die Waechter-Zeile (Exit $rc)"
	elif ! grep -qF -- "fuehrt '$ziel' nicht" <<<"$flach"; then
		grund="der Aufruf nennt die fehlende Ziel-Definition nicht (rot aus falschem Grund?)"
	fi
	if [ -n "$grund" ]; then
		echo "full-smoke: FEHLER — $kennung (DOC_GATE_ZIEL auf der Kommandozeile, $ziel): $grund. Ausgabe:" >&2
		printf '%s\n' "$out" >&2
		exit 1
	fi
	echo "full-smoke: Zieldefinition ($kennung): die Kommandozeile setzt die Entscheidung nicht — make $ziel bricht LAUT ab, statt zu binden."
}

vorlauf_waechter_im_ziel() {
	local repo="$1" kennung="$2"
	local klon="$tmpklon/flach" voll="$tmpklon/voll"
	local kette="" kette_rc=0 kette_commits="" kette_commits_rc=0
	local z_guard="" z_docker="" fehlt="" tiefe=""

	# (a) DIE KETTE DES ZIELS, an SEINER Kante gelesen (`make -n` fuehrt kein Rezept aus):
	# der Waechter steht VOR dem Modul-Lauf, nicht daneben. Belegt wird die ORDNUNG — ein
	# "beides kommt vor" haette keine, und `make -j` faehrt die Vorbedingungen eines Ziels
	# vor dessen Rezept.
	kette="$( make --no-print-directory -C "$repo" -n doc-immutable RANGE=HEAD..HEAD 2>&1 )" || kette_rc=$?
	kette_commits="$( make --no-print-directory -C "$repo" -n doc-commits RANGE=HEAD..HEAD 2>&1 )" || kette_commits_rc=$?
	if [ "$kette_rc" -ne 0 ] || [ "$kette_commits_rc" -ne 0 ]; then
		echo "full-smoke: FEHLER — $kennung: die Kette des Ziels ist nicht lesbar (make -n, Exit $kette_rc/$kette_commits_rc):" >&2
		printf '%s\n' "$kette" "$kette_commits" >&2
		exit 1
	fi
	z_guard="$(grep -nF 'history-range-guard.sh' <<<"$kette" | sed -n '1p' | cut -d: -f1)"
	z_docker="$(grep -nF 'docker run' <<<"$kette" | sed -n '1p' | cut -d: -f1)"
	if [ -z "$z_guard" ]; then fehlt="$fehlt [doc-immutable nennt den Waechter nicht]"; fi
	if [ -z "$z_docker" ]; then fehlt="$fehlt [doc-immutable nennt den Modul-Lauf nicht]"; fi
	if [ -n "$z_guard" ] && [ -n "$z_docker" ] && [ "$z_guard" -ge "$z_docker" ]; then
		fehlt="$fehlt [der Waechter steht NACH dem Modul-Lauf: Zeile $z_guard gegen $z_docker]"
	fi
	if ! grep -qF 'history-range-guard.sh' <<<"$kette_commits"; then
		fehlt="$fehlt [doc-commits nennt den Waechter nicht]"
	fi
	if [ -n "$fehlt" ]; then
		echo "full-smoke: FEHLER — $kennung: die Kette des Ziels ist nicht die zugesagte:$fehlt (LH-QA-01). Ausgabe:" >&2
		printf '%s\n' "$kette" >&2
		exit 1
	fi

	# ECHTE Historie: eine leere Range gibt es nur, wo Commits liegen. Der zweite Commit ist
	# leer (--allow-empty) — gemessen wird die Historie, nicht ein Diff.
	if ! git -C "$repo" -c user.email=full-smoke@example.invalid -c user.name=full-smoke add -A; then
		echo "full-smoke: FEHLER — $kennung: der gebootstrappte Baum liess sich nicht in den Index nehmen." >&2
		exit 1
	fi
	if ! git -C "$repo" -c user.email=full-smoke@example.invalid -c user.name=full-smoke commit -q -m "Bootstrap (full-smoke)"; then
		echo "full-smoke: FEHLER — $kennung: der Bootstrap-Commit ist nicht entstanden." >&2
		exit 1
	fi
	if ! git -C "$repo" -c user.email=full-smoke@example.invalid -c user.name=full-smoke commit -q --allow-empty -m "zweiter Commit (full-smoke)"; then
		echo "full-smoke: FEHLER — $kennung: der zweite Commit ist nicht entstanden — ohne ihn traegt die volle Range nichts." >&2
		exit 1
	fi
	# ZWEI KLONE DERSELBEN QUELLE, ein Unterschied: --depth 1. `file://` ist Pflicht — bei
	# einem lokalen Pfad ignoriert git die Tiefe und legt einen vollstaendigen Klon an.
	if ! git clone -q --depth 1 "file://$repo" "$klon"; then
		echo "full-smoke: FEHLER — $kennung: der flache Klon ist nicht entstanden." >&2
		exit 1
	fi
	if ! git clone -q "file://$repo" "$voll"; then
		echo "full-smoke: FEHLER — $kennung: der vollstaendige Klon ist nicht entstanden." >&2
		exit 1
	fi
	# Vorbedingung der Sonde: der flache Klon muss wirklich flach sein. Traegt er die
	# Historie, misst der naechste Schritt einen anderen Fall als den zugesagten.
	tiefe="$(git -C "$klon" rev-list --count HEAD)"
	if [ "$tiefe" -ne 1 ]; then
		echo "full-smoke: FEHLER — $kennung: der Klon der Tiefe 1 traegt $tiefe Commit(s), nicht 1 — die Sonde misst einen anderen Fall." >&2
		exit 1
	fi

	# (b) DER ANLASS, an BEIDEN history-lesenden Targets: eine aufloesbare, aber LEERE Range.
	waechter_bricht_ab "$klon" doc-immutable "HEAD..HEAD" "ist aufloesbar, aber LEER" "$kennung"
	waechter_bricht_ab "$klon" doc-commits "HEAD..HEAD" "ist aufloesbar, aber LEER" "$kennung"

	# (c) DIE GRENZE, benannt statt ueberdehnt: eine UNAUFLOESBARE Basis bricht ebenfalls ab
	# — hier deckt der Waechter nur dieselbe Klasse VOR dem teureren Image-Lauf; ohne ihn
	# faellt der Modul-Lauf selbst. Dieselbe Range dient unten als Gegenprobe auf dem
	# vollstaendigen Klon.
	waechter_bricht_ab "$klon" doc-immutable "HEAD~1..HEAD" "ist NICHT aufloesbar" "$kennung"

	# (d) OHNE DEN WAECHTER ist dieselbe leere Range "0 Befund(e)", Exit 0 — genau die
	# Klasse, gegen die er steht. Gefahren wird d-check.mk DIREKT: das Modul ohne das
	# Doc-Gate-Fragment (dieselbe Form wie `make smoke`, `-f d-check.mk`) — und zwar an
	# beiden history-lesenden Targets, weil die Zusage des Fragments beide nennt.
	blind_gruen_ohne_waechter "$klon" doc-immutable "$kennung"
	blind_gruen_ohne_waechter "$klon" doc-commits "$kennung"

	# (e) DIE GEGENPROBE: derselbe Aufruf auf einem VOLLSTAENDIGEN Klon derselben Quelle,
	# mit der Range, die der flache Klon nicht aufloesen konnte. Er bleibt gruen — der
	# Waechter faerbt nichts rot, wo Historie da ist, und das Modul laeuft wirklich.
	local voll_out="" voll_rc=0 vollgrund="" vollflach=""
	voll_out="$( make --no-print-directory -C "$voll" doc-immutable RANGE=HEAD~1..HEAD 2>&1 )" || voll_rc=$?
	vollflach="$(tr -s '[:space:]' ' ' <<<"$voll_out")"
	if [ "$voll_rc" -ne 0 ]; then
		vollgrund="derselbe Aufruf endet auf dem vollstaendigen Klon mit Exit $voll_rc statt mit 0"
	elif ! grep -qF -- 'aufgeloest, 1 Commit(s) — OK' <<<"$vollflach"; then
		vollgrund="der Waechter meldet den aufgeloesten Lauf nicht"
	elif ! grep -qF -- 'Datei(en) geprüft' <<<"$vollflach"; then
		vollgrund="der Modul-Lauf fand nicht statt — das Gruen waere dann keines des Moduls"
	fi
	if [ -n "$vollgrund" ]; then
		echo "full-smoke: FEHLER — $kennung (vollstaendiger Klon): $vollgrund. Ausgabe:" >&2
		printf '%s\n' "$voll_out" >&2
		einordnen "make doc-immutable im vollstaendigen Klon ($kennung)" "$voll_out"
		exit 1
	fi
	echo "full-smoke: Gegenprobe ($kennung): dieselbe Range auf dem vollstaendigen Klon bleibt gruen —"
	grep -F -- 'aufgeloest, 1 Commit(s) — OK' <<<"$voll_out" | sed -n '1p' | sed 's/^/full-smoke:   /'
	grep -F -- 'Datei(en) geprüft' <<<"$voll_out" | sed -n '1p' | sed 's/^/full-smoke:   /'

	# (f) DIE VORBINDUNG UEBER EINEM d-check.mk OHNE ZIEL-DEFINITION, am gebootstrappten Baum:
	# die Vorbindungs-Zeile setzt voraus, dass das Ziel dort MIT REZEPT definiert ist. Die
	# fail-closed Zeile des Fragments haelt den Fall auf, in dem make allein den Waechter faehrt
	# und das Modul nicht (Exit 0). Verfaelscht wird die DEFINITION — die Ziel-Zeile umbenannt
	# bzw. ihr Rezept entfernt, die .PHONY-Marke bleibt stehen: geprueft ist die Definition mit
	# Rezept, nicht die Marke. Beide Richtungen ueber demselben Klon: mit verfaelschtem
	# d-check.mk der laute Abbruch, ueber dem unverfaelschten das Gruen aus (e) fuer
	# doc-immutable und der Modul-Lauf fuer doc-commits.
	cp "$voll/d-check.mk" "$voll/d-check.mk.orig"
	sed -i -E 's/^(doc-immutable|doc-commits):/doc-ohne-definition-\1:/' "$voll/d-check.mk"
	vorbindung_ohne_zieldefinition "$voll" doc-immutable "$kennung"
	vorbindung_ohne_zieldefinition "$voll" doc-commits "$kennung"
	# Zweiter Auslöser derselben Klasse: die Ziel-Zeile bleibt, ihr Rezept geht — an BEIDEN
	# Zielen, denn die Probe ist EINE Quelle und beide Aufrufer lesen sie.
	cp "$voll/d-check.mk.orig" "$voll/d-check.mk"
	sed -i '/^doc-immutable:/{n;d}' "$voll/d-check.mk"
	vorbindung_ohne_zieldefinition "$voll" doc-immutable "$kennung"
	cp "$voll/d-check.mk.orig" "$voll/d-check.mk"
	sed -i '/^doc-commits:/{n;d}' "$voll/d-check.mk"
	vorbindung_ohne_zieldefinition "$voll" doc-commits "$kennung"
	# Drittens die Randlage: dasselbe verfaelschte d-check.mk OHNE das Probe-Werkzeug im PATH.
	# Ein unbekannter Ausgang darf nicht in den permissiven Zweig fallen.
	cp "$voll/d-check.mk.orig" "$voll/d-check.mk"
	sed -i -E 's/^(doc-immutable|doc-commits):/doc-ohne-definition-\1:/' "$voll/d-check.mk"
	vorbindung_ohne_probewerkzeug "$voll" doc-immutable "$kennung"
	# Viertens die Zusage gegen den Aufruf: DOC_GATE_ZIEL=da auf der Kommandozeile setzt die
	# Entscheidung nicht ausser Kraft.
	vorbindung_gegen_die_kommandozeile "$voll" doc-immutable "$kennung"
	mv "$voll/d-check.mk.orig" "$voll/d-check.mk"
	vorbindung_mit_zieldefinition "$voll" doc-commits "$kennung"
}

vorlauf_waechter_im_ziel "$tmprepo" "golang"

# ZAEHNE zur Ortswahl aus slice-098 (AGENTS.md §3.6): dass die Feldliste DA ist, sagt noch
# nicht, dass das Doku-Gate des Ziels sie LIEST — genau das unterscheidet den geprueften
# Bereich von .harness/**, das die emittierte .d-check.yml ausnimmt. Ein toter relativer
# Verweis im Dokument MUSS das docs-check des Ziels roetten, und der Befund muss diese
# Datei nennen. Danach zuruecknehmen: die Datei ist konvergent, aber der Rest des Smokes
# laeuft auf dem heilen Stand (dieselbe Disziplin wie beim Arch-Gate-Zahn unten).
feld_doc="$tmprepo/$FELDLISTE_REL"
cp "$feld_doc" "$feld_doc.orig"
printf '\n[toter Verweis](./gibt-es-nicht.md)\n' >>"$feld_doc"
feldzahn_rc=0
feldzahn_out="$( make -C "$tmprepo" docs-check 2>&1 )" || feldzahn_rc=$?
mv "$feld_doc.orig" "$feld_doc"
if [ "$feldzahn_rc" -eq 0 ]; then
	echo "full-smoke: FEHLER — ein toter Verweis in $FELDLISTE_REL laesst das docs-check des Ziels GRUEN: das Dokument liegt ausserhalb des geprueften Bereichs (slice-098/AGENTS.md §3.6)." >&2
	printf '%s\n' "$feldzahn_out" >&2
	exit 1
fi
if ! grep -qE "$FELDLISTE_REL:[0-9]+.*target-missing" <<<"$feldzahn_out"; then
	echo "full-smoke: FEHLER — docs-check des Ziels rot, aber ohne Befund AUF der Feldliste (rot aus falschem Grund? slice-098). Ausgabe:" >&2
	printf '%s\n' "$feldzahn_out" >&2
	einordnen "make docs-check im Ziel (Feldlisten-Zahn)" "$feldzahn_out"
	exit 1
fi
echo "full-smoke: Feldlisten-Ortswahl belegt (toter Verweis im Dokument faerbt das docs-check des Ziels rot, danach zurueckgenommen):"
grep -E "$FELDLISTE_REL:[0-9]+" <<<"$feldzahn_out" | sed -n '1,2s/^/full-smoke:   /p'

# ZAEHNE zu den drei in der emittierten Konfiguration aktiven Modulen ids/matrix/spans —
# VIER Gegenbeispiele im gebootstrappten Ziel (AGENTS.md §3.6), nach derselben Form wie der
# Feldlisten-Zahn oben: Verletzung einschmuggeln -> docs-check MUSS roeten, MIT der
# benannten Befund-Art -> zurueckgenommen. matrix traegt zwei Regeln und damit zwei eigene
# Zaehne (matrix-forbidden, matrix-downward); eine Regel ohne eigenes Gegenbeispiel waere
# gelistet-aber-unbewacht. Die ZWEITE Richtung gehoert bei allen vier dazu: dieselbe
# Verletzung MUSS unter dem AELTEREN modules: [links, anchors] gruen bleiben — sonst
# belegt der Zahn nur "irgendein Modul faengt es", nicht "ERST dieses Modul findet sie".
modul_zahn_alte_module_gruen() {
	local repo="$1" kennung="$2"
	local out="" rc=0
	cp "$repo/.d-check.yml" "$repo/.d-check.yml.zahn-bak"
	sed -i 's/^modules: \[links, anchors, ids, matrix, spans\]$/modules: [links, anchors]/' "$repo/.d-check.yml"
	out="$( make -C "$repo" docs-check 2>&1 )" || rc=$?
	mv "$repo/.d-check.yml.zahn-bak" "$repo/.d-check.yml"
	if [ "$rc" -ne 0 ]; then
		echo "full-smoke: FEHLER — $kennung: dieselbe Verletzung faerbt auch unter dem VORHERIGEN modules: [links, anchors] rot — der Zahn belegt nicht, dass ERST das neue Modul sie findet (slice-073)." >&2
		printf '%s\n' "$out" >&2
		einordnen "make docs-check im Ziel unter modules: [links, anchors] ($kennung)" "$out"
		exit 1
	fi
}

# (1) matrix-forbidden: eine spec-straten -> adr Referenz (Referenz-Richtung SDP verboten).
matrix_doc="$tmprepo/spec/lastenheft.md"
matrix_adr="$tmprepo/docs/plan/adr/9999-smoke-zahn.md"
cp "$matrix_doc" "$matrix_doc.orig"
printf '# ADR-9999: Smoke-Zahn\n\n**Status:** Accepted\n\n## Kontext\n\nSmoke.\n' >"$matrix_adr"
sed -i '5a\
\
Siehe [ADR-9999](../docs/plan/adr/9999-smoke-zahn.md) fuer Kontext.
' "$matrix_doc"
matrixzahn_rc=0
matrixzahn_out="$( make -C "$tmprepo" docs-check 2>&1 )" || matrixzahn_rc=$?
if [ "$matrixzahn_rc" -eq 0 ]; then
	echo "full-smoke: FEHLER — matrix-Zahn: eine spec-straten->adr Referenz laesst docs-check im Ziel GRUEN: matrix nicht wirksam (slice-073/AGENTS.md §3.6)." >&2
	printf '%s\n' "$matrixzahn_out" >&2
	exit 1
fi
if ! grep -qE 'matrix-forbidden' <<<"$matrixzahn_out"; then
	echo "full-smoke: FEHLER — matrix-Zahn: docs-check im Ziel rot, aber ohne matrix-forbidden (rot aus falschem Grund? slice-073). Ausgabe:" >&2
	printf '%s\n' "$matrixzahn_out" >&2
	einordnen "make docs-check im Ziel (matrix-Zahn)" "$matrixzahn_out"
	exit 1
fi
echo "full-smoke: matrix-Zahn belegt (spec-straten->adr Referenz faerbt matrix im Ziel rot, danach zurueckgenommen):"
grep -E 'matrix-forbidden' <<<"$matrixzahn_out" | sed -n '1,2s/^/full-smoke:   /p'
modul_zahn_alte_module_gruen "$tmprepo" "matrix-Zahn"
mv "$matrix_doc.orig" "$matrix_doc"
rm -f "$matrix_adr"

# (2) matrix-downward: ein Abwaertslink Vertrag -> Technik INNERHALB der Spec-Straten
# (order:/direction: no-downward auf der spec-straten-Klasse).
matrixdown_doc="$tmprepo/spec/lastenheft.md"
cp "$matrixdown_doc" "$matrixdown_doc.orig"
sed -i '5a\
\
Siehe [spec/spezifikation.md](spezifikation.md) fuer Details (Abwaertslink, Zahn).
' "$matrixdown_doc"
matrixdownzahn_rc=0
matrixdownzahn_out="$( make -C "$tmprepo" docs-check 2>&1 )" || matrixdownzahn_rc=$?
if [ "$matrixdownzahn_rc" -eq 0 ]; then
	echo "full-smoke: FEHLER — matrix-downward-Zahn: ein Abwaertslink Vertrag->Technik laesst docs-check im Ziel GRUEN: order:/direction: nicht wirksam (slice-073/AGENTS.md §3.6)." >&2
	printf '%s\n' "$matrixdownzahn_out" >&2
	exit 1
fi
if ! grep -qE 'matrix-downward' <<<"$matrixdownzahn_out"; then
	echo "full-smoke: FEHLER — matrix-downward-Zahn: docs-check im Ziel rot, aber ohne matrix-downward (rot aus falschem Grund? slice-073). Ausgabe:" >&2
	printf '%s\n' "$matrixdownzahn_out" >&2
	einordnen "make docs-check im Ziel (matrix-downward-Zahn)" "$matrixdownzahn_out"
	exit 1
fi
echo "full-smoke: matrix-downward-Zahn belegt (Abwaertslink Vertrag->Technik faerbt matrix im Ziel rot, danach zurueckgenommen):"
grep -E 'matrix-downward' <<<"$matrixdownzahn_out" | sed -n '1,2s/^/full-smoke:   /p'
modul_zahn_alte_module_gruen "$tmprepo" "matrix-downward-Zahn"
mv "$matrixdown_doc.orig" "$matrixdown_doc"

# (3) id-unlinked: eine bare ADR-Kennung (kein Link) — link-policy: always verlangt einen
# klickbaren Verweis auch in Prosa.
ids_doc="$tmprepo/spec/lastenheft.md"
cp "$ids_doc" "$ids_doc.orig"
sed -i '5a\
\
Siehe ADR-9998 fuer Kontext (bare Kennung, kein Link).
' "$ids_doc"
idszahn_rc=0
idszahn_out="$( make -C "$tmprepo" docs-check 2>&1 )" || idszahn_rc=$?
if [ "$idszahn_rc" -eq 0 ]; then
	echo "full-smoke: FEHLER — ids-Zahn: eine bare ADR-Kennung laesst docs-check im Ziel GRUEN: ids nicht wirksam (slice-073/AGENTS.md §3.6)." >&2
	printf '%s\n' "$idszahn_out" >&2
	exit 1
fi
if ! grep -qE 'id-unlinked' <<<"$idszahn_out"; then
	echo "full-smoke: FEHLER — ids-Zahn: docs-check im Ziel rot, aber ohne id-unlinked (rot aus falschem Grund? slice-073). Ausgabe:" >&2
	printf '%s\n' "$idszahn_out" >&2
	einordnen "make docs-check im Ziel (ids-Zahn)" "$idszahn_out"
	exit 1
fi
echo "full-smoke: ids-Zahn belegt (bare ADR-Kennung faerbt ids im Ziel rot, danach zurueckgenommen):"
grep -E 'id-unlinked' <<<"$idszahn_out" | sed -n '1,2s/^/full-smoke:   /p'
modul_zahn_alte_module_gruen "$tmprepo" "ids-Zahn"
mv "$ids_doc.orig" "$ids_doc"

# (4) span-unclosed: ein nicht geschlossener Inline-Code-Span.
spans_doc="$tmprepo/spec/lastenheft.md"
cp "$spans_doc" "$spans_doc.orig"
printf '\nEin `ungeschlossener Code-Span.\n' >>"$spans_doc"
spanszahn_rc=0
spanszahn_out="$( make -C "$tmprepo" docs-check 2>&1 )" || spanszahn_rc=$?
if [ "$spanszahn_rc" -eq 0 ]; then
	echo "full-smoke: FEHLER — spans-Zahn: ein ungeschlossener Code-Span laesst docs-check im Ziel GRUEN: spans nicht wirksam (slice-073/AGENTS.md §3.6)." >&2
	printf '%s\n' "$spanszahn_out" >&2
	exit 1
fi
if ! grep -qE 'span-unclosed' <<<"$spanszahn_out"; then
	echo "full-smoke: FEHLER — spans-Zahn: docs-check im Ziel rot, aber ohne span-unclosed (rot aus falschem Grund? slice-073). Ausgabe:" >&2
	printf '%s\n' "$spanszahn_out" >&2
	einordnen "make docs-check im Ziel (spans-Zahn)" "$spanszahn_out"
	exit 1
fi
echo "full-smoke: spans-Zahn belegt (ungeschlossener Code-Span faerbt spans im Ziel rot, danach zurueckgenommen):"
grep -E 'span-unclosed' <<<"$spanszahn_out" | sed -n '1,2s/^/full-smoke:   /p'
modul_zahn_alte_module_gruen "$tmprepo" "spans-Zahn"
mv "$spans_doc.orig" "$spans_doc"

# slice-099 (LH-FA-10 §Leser und §Aufbewahrung / ADR-0022 Festlegung 8 und 6 Stueck 2):
# DER LESER LAEUFT IM ZIEL UEBER DESSEN EIGENEM BESTAND, UND DAS AUFRAEUM-KOMMANDO IST DA.
#
# Nur ein echter Lauf kann das zeigen. Ein Go-Waechter misst den Text des Fragments; ob
# das gebootstrappte Repo mit `make span-report` wirklich beim Leser ankommt, entscheidet
# die Kette Aggregator -> Fragment -> abgelegter Traeger -> Bestand, und die gibt es nur
# hier. Der GRUND-SATZ hat aus demselben Grund keinen Go-Waechter: die Zusage ist, dass
# ein Adopter ihn in seinem Repo liest.
#
# VIER SCHRITTE, VIER AUSSAGEN:
#   (a) das `gates` des Ziels haengt an keinem der beiden Ziele — gemessen an SEINER
#       Kette (make -n), nicht an unserer Vorstellung davon,
#   (b) ueber dem eben geschriebenen Bestand nennt der Leser seine ABDECKUNG ZUERST,
#       weist KEINE Bilanz aus und nennt den GRUND seiner Leere,
#   (c) das Fragment sagt, was es nicht zusagt: ohne Aufruf waechst der Bestand
#       unbegrenzt,
#   (d) `make span-clean` entfernt den Bestand, und danach meldet der Leser die LEERE
#       DES BESTANDS — nicht dieselbe Meldung wie in (b).
#
# Rot-Gegenbeispiel: test/mutations/176 nimmt den Grund-Satz aus der Ausgabe.
leser_und_aufraeumen_im_ziel() {
	local repo="$1" kennung="$2"
	local spans="$repo/.harness/state/spans"
	local frag="$repo/harness/mk/erfassung.mk"
	local grund="Die Verbrauchs-Zaehler kommen aus der Mechanik des Agenten-Werkzeugs nicht"

	# (a) Die Kette DES ZIELS. `make -n` druckt, was `gates` faehrt, ohne es zu fahren.
	local kette_out="" kette_rc=0
	kette_out="$( make --no-print-directory -C "$repo" -n gates 2>&1 )" || kette_rc=$?
	if [ "$kette_rc" -ne 0 ]; then
		echo "full-smoke: FEHLER — $kennung: die gates-Kette des Ziels ist nicht lesbar (make -n gates, Exit $kette_rc):" >&2
		printf '%s\n' "$kette_out" >&2
		exit 1
	fi
	if grep -qE 'span-(report|clean)' <<<"$kette_out"; then
		echo "full-smoke: FEHLER — $kennung: die gates-Kette des Ziels nennt span-report/span-clean — ein Gate ueber einem Bericht ist eines ueber leerem Pruefbereich (LH-QA-01, slice-099)." >&2
		grep -nE 'span-(report|clean)' <<<"$kette_out" >&2
		exit 1
	fi

	# (b) Der Leser ueber dem echten Bestand des Ziels.
	if [ -z "$(find "$spans" -name '*.jsonl' -type f 2>/dev/null | head -n 1)" ]; then
		echo "full-smoke: FEHLER — $kennung: kein Bestand im Ziel, bevor der Leser laeuft — dieser Zahn misst dann den leeren Fall (slice-099)." >&2
		exit 1
	fi
	local bericht="" bericht_rc=0
	bericht="$( make --no-print-directory -C "$repo" span-report 2>&1 )" || bericht_rc=$?
	if [ "$bericht_rc" -ne 0 ]; then
		echo "full-smoke: FEHLER — $kennung: make span-report im Ziel endet mit Exit $bericht_rc — ein Bericht faerbt nichts rot (slice-099):" >&2
		printf '%s\n' "$bericht" >&2
		einordnen "make span-report im Ziel ($kennung)" "$bericht"
		exit 1
	fi
	local erste
	erste="$(sed -n '1p' <<<"$bericht")"
	case "$erste" in
	Abdeckung:*) ;;
	*)
		echo "full-smoke: FEHLER — $kennung: der Leser nennt seine Abdeckung nicht ZUERST; erste Zeile: [$erste] (LH-FA-10 §Leser, slice-099)." >&2
		printf '%s\n' "$bericht" >&2
		exit 1
		;;
	esac
	# Leerraum-normalisiert, damit der Zeilenumbruch der Ausgabe den Vergleich nicht traegt.
	local flach
	flach="$(tr -s '[:space:]' ' ' <<<"$bericht")"
	if ! grep -qF -- "$grund" <<<"$flach"; then
		echo "full-smoke: FEHLER — $kennung: der Leser meldet seine Leere OHNE ihren Grund — die Abdeckungs-Zeile nennt einen Zustand, erst der Satz nennt die Grenze (ADR-0021 Folgepflicht 6, slice-099). Ausgabe:" >&2
		printf '%s\n' "$bericht" >&2
		exit 1
	fi
	if ! grep -qF -- "Keine Bilanz:" <<<"$flach"; then
		echo "full-smoke: FEHLER — $kennung: der Leser sagt nicht, dass er keine Bilanz ausweist (slice-099). Ausgabe:" >&2
		printf '%s\n' "$bericht" >&2
		exit 1
	fi
	if grep -qF -- "Groesste Rolle" <<<"$flach"; then
		echo "full-smoke: FEHLER — $kennung: der Leser weist ueber einem Bestand OHNE Verbrauchs-Zaehler eine Bilanz aus (slice-099). Ausgabe:" >&2
		printf '%s\n' "$bericht" >&2
		exit 1
	fi

	# (c) Die Nicht-Zusage steht im Ziel geschrieben, nicht nur in unserem Kopf.
	if [ ! -f "$frag" ]; then
		echo "full-smoke: FEHLER — $kennung: das Aufraeum- und Berichts-Fragment fehlt im Ziel (harness/mk/erfassung.mk, slice-099)." >&2
		exit 1
	fi
	local fragflach
	fragflach="$(tr -s '[:space:]' ' ' <"$frag")"
	if ! grep -qF -- "OHNE DIESEN AUFRUF WAECHST DER BESTAND UNBEGRENZT." <<<"$fragflach"; then
		echo "full-smoke: FEHLER — $kennung: das Ziel sagt nicht, dass sein Bestand ohne den Aufruf unbegrenzt waechst (LH-FA-10 §Aufbewahrung, slice-099)." >&2
		exit 1
	fi

	# (d) Aufraeumen — ausdruecklich, und danach ist der Bestand weg.
	local clean_out="" clean_rc=0
	clean_out="$( make --no-print-directory -C "$repo" span-clean 2>&1 )" || clean_rc=$?
	if [ "$clean_rc" -ne 0 ] || [ -e "$spans" ]; then
		echo "full-smoke: FEHLER — $kennung: make span-clean endet mit Exit $clean_rc oder laesst den Bestand liegen (slice-099):" >&2
		printf '%s\n' "$clean_out" >&2
		exit 1
	fi
	local leer="" leer_rc2=0
	leer="$( make --no-print-directory -C "$repo" span-report 2>&1 )" || leer_rc2=$?
	local leerflach
	leerflach="$(tr -s '[:space:]' ' ' <<<"$leer")"
	# ZWEI BEDINGUNGEN, ZWEI MELDUNGEN: ein Absturz des Berichts und eine Ausgabe ohne
	# die Leere-Meldung sind verschiedene Fehler, und eine gemeinsame Kopfzeile waere in
	# einem der beiden Faelle die falsche Begruendung.
	if [ "$leer_rc2" -ne 0 ]; then
		echo "full-smoke: FEHLER — $kennung: make span-report ueber dem geraeumten Bestand endet mit Exit $leer_rc2 — ein Bericht faerbt nichts rot (slice-099):" >&2
		printf '%s\n' "$leer" >&2
		einordnen "make span-report ueber dem geraeumten Bestand ($kennung)" "$leer"
		exit 1
	fi
	if ! grep -qF -- "Kein Bestand:" <<<"$leerflach"; then
		echo "full-smoke: FEHLER — $kennung: ueber dem geraeumten Bestand meldet der Leser nicht dessen Leere (slice-099):" >&2
		printf '%s\n' "$leer" >&2
		exit 1
	fi
	if grep -qF -- "$grund" <<<"$leerflach"; then
		echo "full-smoke: FEHLER — $kennung: der LEERE Bestand bekommt die Begruendung des zaehlerlosen — ohne Zeile gibt es nichts, was Zaehler tragen koennte (slice-099):" >&2
		printf '%s\n' "$leer" >&2
		exit 1
	fi

	# (e) DIE VIERTE LAGE, und sie liegt VOR den drei Lagen des Lesers: der Traeger
	# fehlt. Dann startet das Fragment das Go-Programm gar nicht — es meldet die
	# Abwesenheit selbst, statt auf ein fehlendes Programm zu zeigen (LH-QA-01). Ein
	# frischer Klon des Adopter-Repos ist genau dieser Fall.
	#
	# NUR HIER MESSBAR: die Schleife liegt im Makefile-Rezept, kein Go-Test faehrt make.
	# Der Traeger wird beiseitegelegt und danach zurueckgeholt — dieselbe Disziplin wie
	# bei den uebrigen Zaehne-Beweisen.
	#
	# Der ZWEITE Satz ist der tragende: ohne ihn liest ein Adopter die Stille als Aussage
	# ueber seinen Bestand, waehrend sie eine ueber den Leser ist.
	# Rot-Gegenbeispiel: test/mutations/186-bericht-ohne-leser-schweigt-falsch.sh.
	local carrier="$repo/.harness/state/bin/ai-harness-init"
	if [ ! -x "$carrier" ]; then
		echo "full-smoke: FEHLER — $kennung: der Traeger liegt nicht, bevor er beiseitegelegt wird — dieser Zahn misst dann den falschen Zweig (slice-099)." >&2
		exit 1
	fi
	mv "$carrier" "$carrier.beiseite"
	local ohne="" ohne_rc=0
	ohne="$( make --no-print-directory -C "$repo" span-report 2>&1 )" || ohne_rc=$?
	mv "$carrier.beiseite" "$carrier"
	if [ "$ohne_rc" -ne 0 ]; then
		echo "full-smoke: FEHLER — $kennung: ohne Traeger endet make span-report mit Exit $ohne_rc — ein fehlender Leser ist kein Fehler des Repos (slice-099):" >&2
		printf '%s\n' "$ohne" >&2
		einordnen "make span-report ohne Traeger ($kennung)" "$ohne"
		exit 1
	fi
	local ohneflach fehlt="" satz
	ohneflach="$(tr -s '[:space:]' ' ' <<<"$ohne")"
	for satz in "der Traeger liegt nicht" \
	            "das ist KEINE Aussage ueber den Bestand, sondern ueber den Leser" \
	            "ein erneuter Lauf des Werkzeugs legt ihn wieder ab"; do
		grep -qF -- "$satz" <<<"$ohneflach" || fehlt="$fehlt [$satz]"
	done
	if [ -n "$fehlt" ]; then
		echo "full-smoke: FEHLER — $kennung: ohne Traeger sagt make span-report nicht, was fehlt und was das NICHT heisst:$fehlt (slice-099). Ausgabe:" >&2
		printf '%s\n' "$ohne" >&2
		exit 1
	fi
	if grep -qF -- "Abdeckung:" <<<"$ohneflach"; then
		echo "full-smoke: FEHLER — $kennung: ohne Traeger meldet make span-report eine Abdeckung — dann laeuft ein Leser, den es nicht gibt (slice-099):" >&2
		printf '%s\n' "$ohne" >&2
		exit 1
	fi
	echo "full-smoke: Leser + Aufraeum-Kommando im Ziel ($kennung): Abdeckung zuerst, keine Bilanz, Grund genannt; span-clean raeumt; der geraeumte Bestand meldet seine eigene Leere, und ohne Traeger meldet das Ziel den fehlenden Leser."
}

# slice-096 (LH-FA-10 / ADR-0022 Festlegung 1 und 5): DER TRAEGER LIEGT IM ZIEL.
# Der Nachbau dessen, was `make span-check` fuer den DOGFOOD leistet — am gebootstrappten
# ZIEL und ueber den Weg, den das Agenten-Werkzeug dort wirklich nimmt:
#   (a) der Traeger liegt im gitignorierten Zustands-Bereich und ist ausfuehrbar,
#   (b) die emittierte .claude/settings.json ruft den WRAPPER, nie den Traeger direkt —
#       eine Konfiguration, die direkt auf den gitignorierten Ort zeigte, waere ein Hook
#       auf ein fehlendes Programm, sobald ein frischer Klon ihn nicht mitbringt,
#   (c) der Wrapper erzeugt aus einer synthetischen Payload einen Span mit der VOLLEN
#       Pflicht-Spalte (spec/spezifikation.md §5) — nicht mit einer Auswahl,
#   (d) `git check-ignore` IM ZIEL bestaetigt dessen Ablageort: ein Span im getrackten
#       Baum verschoebe dort den working-tree-hash bei jedem Tool-Call (MR-003),
#   (e) ohne Traeger schweigt der Wrapper und endet mit 0 — der Fall des frischen Klons.
#
# Nur der ECHTE Lauf kann das zeigen: das laufende Bild eines Go-Testlaufs ist das
# Test-Binary und taugt nicht als Traeger. Aufgerufen wird die Pruefung fuer BEIDE
# Bootstrap-Varianten — die Erfassung ist sprach-agnostisch, ein Zahn in nur einer
# Variante belegte das nicht.
#
# Rot-Gegenbeispiel: test/mutations/160 legt den Traeger ohne Ausfuehrungsrecht ab.
traeger_im_ziel() {
	local repo="$1" kennung="$2"
	local carrier="$repo/.harness/state/bin/ai-harness-init"
	local wrapper="$repo/.claude/hooks/span-emit.sh"

	if [ ! -x "$carrier" ]; then
		echo "full-smoke: FEHLER — $kennung: der Traeger fehlt oder ist nicht ausfuehrbar (.harness/state/bin/ai-harness-init) — der Hook startet ihn je Tool-Call (slice-096)." >&2
		exit 1
	fi
	if [ ! -x "$wrapper" ]; then
		echo "full-smoke: FEHLER — $kennung: der Hook-Wrapper fehlt oder ist nicht ausfuehrbar (.claude/hooks/span-emit.sh) — er entsteht mit dem Traeger (slice-096)." >&2
		exit 1
	fi
	local hook_missing="" marker
	for marker in '"PostToolUse"' '"PostToolUseFailure"' '"SubagentStart"' '.claude/hooks/span-emit.sh'; do
		if ! grep -qF -- "$marker" "$repo/.claude/settings.json"; then
			hook_missing="$hook_missing [$marker]"
		fi
	done
	if [ -n "$hook_missing" ]; then
		echo "full-smoke: FEHLER — $kennung: die emittierte settings.json traegt den Erfassungs-Eintrag nicht:$hook_missing (slice-096)." >&2
		exit 1
	fi
	if grep -qF -- '.harness/state/bin' "$repo/.claude/settings.json"; then
		echo "full-smoke: FEHLER — $kennung: settings.json zeigt DIREKT auf den gitignorierten Ablageort statt auf den Wrapper (LH-QA-01)." >&2
		exit 1
	fi

	# Eigener Strom-Name je Variante, damit die zwei Laeufe einander nie ueberschreiben.
	local stream="fullsmoke$kennung"
	local payload="{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"Bash\",\"tool_use_id\":\"tu_fs\",\"session_id\":\"$stream\",\"tool_input\":{\"command\":\"make gates\"}}"
	local span_out="" span_rc=0
	span_out="$( cd "$repo" && CLAUDE_PROJECT_DIR="$repo" bash "$wrapper" <<<"$payload" )" || span_rc=$?
	if [ "$span_rc" -ne 0 ]; then
		echo "full-smoke: FEHLER — $kennung: der Erfassungs-Hook endete mit Exit $span_rc — ein Nicht-Null-Hook blockt den Tool-Call, den er beobachten soll (ADR-0011 Festlegung 6)." >&2
		exit 1
	fi
	if [ -n "$span_out" ]; then
		echo "full-smoke: FEHLER — $kennung: der Erfassungs-Hook schrieb auf stdout — dort liegt der Entscheidungs-Kanal: [$span_out]" >&2
		exit 1
	fi
	local file=".harness/state/spans/$stream.jsonl"
	if [ ! -s "$repo/$file" ]; then
		echo "full-smoke: FEHLER — $kennung: kein Span im Ziel ($file fehlt oder ist leer) — der abgelegte Traeger schreibt nicht (LH-FA-10 Happy Path)." >&2
		exit 1
	fi
	# Die VOLLE Pflicht-Spalte, dieselbe Liste wie in harness/tools/span-check.sh: eine
	# Auswahl liesse ausgerechnet die Felder ungeprueft, die zuletzt hinzukamen.
	local line feld
	line="$(cat "$repo/$file")"
	for feld in '"seq":1' '"ts":' '"event":' '"tool":"Bash"' '"tool_use_id":"tu_fs"' \
	            '"session":' '"agent":' '"agent_type":' '"agent_role":' '"slice":' '"requirement":' \
	            '"adr":' '"branch":' '"commit":' '"status":"ok"' '"program":"make"'; do
		if ! grep -qF -- "$feld" <<<"$line"; then
			echo "full-smoke: FEHLER — $kennung: Pflichtfeld fehlt im Span des Ziels: $feld — $line" >&2
			exit 1
		fi
	done
	if ! ( cd "$repo" && git check-ignore -q "$file" ); then
		echo "full-smoke: FEHLER — $kennung: der Span liegt im GETRACKTEN Baum des Ziels ($file) — jeder Tool-Call verschoebe dort den working-tree-hash (MR-003)." >&2
		exit 1
	fi
	# slice-098: hier — und nur hier — liegt eine ECHTE Span-Zeile des Ziels vor. Der
	# Abgleich mit der Feldliste gehoert deshalb an diese Stelle, statt eine zweite Zeile
	# eigens dafuer zu erzeugen.
	feldliste_deckt_die_zeile "$repo" "$kennung" "$line"
	# slice-099: hier liegt ein ECHTER Bestand des Ziels — genau der Gegenstand, ueber
	# dem der emittierte Leser laufen soll. Er raeumt am Ende auf; danach ist der
	# Bestand weg, und der Rest dieser Funktion braucht ihn nicht mehr.
	leser_und_aufraeumen_im_ziel "$repo" "$kennung"

	# (e) Ohne Traeger schweigt der Wrapper. Danach zuruecknehmen — der Rest des Smokes
	# laeuft auf dem heilen Stand (dieselbe Disziplin wie bei den Zaehne-Beweisen unten).
	mv "$carrier" "$carrier.beiseite"
	local leer_out="" leer_rc=0
	leer_out="$( cd "$repo" && CLAUDE_PROJECT_DIR="$repo" bash "$wrapper" <<<"$payload" 2>&1 )" || leer_rc=$?
	mv "$carrier.beiseite" "$carrier"
	if [ "$leer_rc" -ne 0 ] || [ -n "$leer_out" ]; then
		echo "full-smoke: FEHLER — $kennung: ohne Traeger endet der Wrapper mit Exit $leer_rc und der Ausgabe [$leer_out] — er soll schweigen und mit 0 enden (slice-096)." >&2
		exit 1
	fi
	rm -rf "${repo:?}/.harness/state/spans"
	echo "full-smoke: OK — $kennung: Traeger + Wrapper + Hook-Eintrag liegen im Ziel; der Hook schrieb einen Span mit voller Pflicht-Spalte an einem git-ignorierten Ort und schweigt ohne Traeger."
}

traeger_im_ziel "$tmprepo" "golang"

# --- Archivierung: das gebootstrappte Ziel erreicht das Unterkommando ---------------
#
# WAS DIE GO-STUFE NICHT SIEHT: sie liest den TEXT des emittierten Fragments. Ob ein
# `make`-Aufruf im gebootstrappten Repo wirklich beim Unterkommando des abgelegten
# Traegers ankommt, entscheidet die Kette Aggregator -> Fragment -> Traeger ->
# vendored Stub-Vorlage — und die gibt es nur hier (ADR-0033 Folgepflicht 8).
#
# FUENF AUSSAGEN:
#   (a) die zwei fail-closed-Sperren `[untergrenze]` und `[haenger]` aus
#       internal/archive erreichen den Aufruf: ueber einem Bestand, der beide
#       ausloest, endet `make archive-welle` nicht erfolgreich und schreibt nichts.
#       Der Exit-Code des Traegers ist hier NICHT lesbar — `make` gibt fuer ein
#       fehlgeschlagenes Rezept immer 2 zurueck —, die zwei Sperren stehen darum
#       in der Ausgabe,
#   (b) ueber demselben Bestand ohne die zwei Ausloeser laeuft die Operation real:
#       Archiv und Stubs liegen danach in done/<welle-id>/,
#   (c) das Kommando ist KEIN Gate: die gates-Kette des Ziels nennt es nicht,
#   (c2) ein Name, den die Anleitung nicht fuehrt, endet laut statt still: der
#       Adopter, der das Ziel umbenennt und nur die skip-if-present-Anleitung
#       zieht, faellt hier auf,
#   (d) ohne Traeger sagt das Kommando das und endet mit 0 — der frische Klon.
#
# NUR HIER MESSBAR: kein Go-Test faehrt `make`, und ein Lauf auf dem HOST findet den
# Traeger eines gebootstrappten Repos nicht.
#
# EINE VARIANTE, und die Grenze steht hier: gefahren wird das --lang-go-Ziel. Das
# Fragment kommt aus enforceFiles() und liegt in BEIDEN Bootstrap-Varianten unter
# demselben Glob; dass es auch sprachlos entsteht, misst
# TestArchivierungFragment_LiegtAuchOhneTraeger ueber einen Emit ohne Sprache.
archivierung_im_ziel() {
	local repo="$1" kennung="$2"
	local frag="$repo/harness/mk/archivierung.mk"
	local carrier="$repo/.harness/state/bin/ai-harness-init"
	local plan_done="$repo/docs/plan/planning/done"
	local reviews="$repo/docs/reviews"
	local welle="welle-smoke"

	if [ ! -f "$frag" ]; then
		echo "full-smoke: FEHLER — $kennung: das Fragment der Wellen-Archivierung liegt nicht im Ziel (harness/mk/archivierung.mk, ADR-0033 Festlegung 4)." >&2
		exit 1
	fi
	if [ ! -x "$carrier" ]; then
		echo "full-smoke: FEHLER — $kennung: der Traeger liegt nicht, bevor dieser Abschnitt ihn ruft — dieser Abschnitt misst dann den falschen Zweig (der Traeger-Abschnitt oben hat ihn abgelegt)." >&2
		exit 1
	fi
	if [ -n "$(git -C "$repo" status --porcelain)" ]; then
		echo "full-smoke: FEHLER — $kennung: der Arbeitsbaum des Ziels ist vor diesem Abschnitt nicht sauber — ein Lauf bricht an seiner eigenen Sauberkeits-Sperre ab, der Fall ist damit nicht der zugesagte:" >&2
		git -C "$repo" status --porcelain >&2
		exit 1
	fi

	# (c) KEIN GATE. `make -n` druckt die Kette, ohne sie zu fahren.
	#
	# DIE VORBEDINGUNG STEHT ZUERST: die Zusicherung "archive-welle steht nicht in
	# der Kette" ist ueber einer leeren Kette still gruen. Gelesen wird darum, dass
	# die Kette die Gate-Rezepte traegt, die jeder Bootstrap fahrt — der Nachweis,
	# die Baseline-Pruefung und der Modul-Lauf in seinem Bild. Die Marker sind
	# REZEPT-Zeilen: `make -n` druckt die Befehle, nicht die Ziel-Namen.
	local kette="" kette_rc=0 fehlt=""
	kette="$( make --no-print-directory -C "$repo" -n gates 2>&1 )" || kette_rc=$?
	if [ "$kette_rc" -ne 0 ]; then
		echo "full-smoke: FEHLER — $kennung: die gates-Kette des Ziels ist nicht lesbar (make -n gates, Exit $kette_rc):" >&2
		printf '%s\n' "$kette" >&2
		exit 1
	fi
	local noetig
	for noetig in 'record-gates.sh' 'baseline-verify.sh' 'docker run'; do
		grep -qF -- "$noetig" <<<"$kette" || fehlt="$fehlt [$noetig]"
	done
	if [ -n "$fehlt" ]; then
		echo "full-smoke: FEHLER — $kennung: die gelesene gates-Kette traegt nicht, was sie tragen muss:$fehlt — der Nicht-Gate-Zahn misst dann einen leeren Pruefbereich." >&2
		printf '%s\n' "$kette" >&2
		exit 1
	fi
	if grep -qF -- 'archive-welle' <<<"$kette"; then
		echo "full-smoke: FEHLER — $kennung: die gates-Kette des Ziels nennt archive-welle — eine Archivierung prueft nichts (LH-QA-01)." >&2
		grep -nF -- 'archive-welle' <<<"$kette" >&2
		exit 1
	fi

	# (c2) EIN NAME, DEN DIE ANLEITUNG NICHT FUEHRT, ENDET LAUT. Die emittierte
	# Anleitung nennt `archive-welle`, und das Fragment fuehrt genau dieses Ziel; der
	# Name daneben kennt `make` nicht. Gemessen wird die Richtung, die den Adopter
	# trifft, der das Ziel umbenennt und nur die skip-if-present-Anleitung zieht:
	# `make` bricht ueber dem unbekannten Namen ab und nennt ihn, statt still nichts
	# zu tun.
	local fremd="" fremd_rc=0
	fremd="$( make --no-print-directory -C "$repo" archiv-welle WELLE="$welle" 2>&1 )" || fremd_rc=$?
	if [ "$fremd_rc" -eq 0 ]; then
		echo "full-smoke: FEHLER — $kennung: make archiv-welle laeuft — ein Ziel, das kein Fragment dieses Repos fuehrt, ist damit still erreichbar." >&2
		printf '%s\n' "$fremd" >&2
		exit 1
	fi
	if ! grep -qF -- 'archiv-welle' <<<"$fremd"; then
		echo "full-smoke: FEHLER — $kennung: der Aufruf bricht ab, nennt den unbekannten Namen aber nicht (rot aus falschem Grund?):" >&2
		printf '%s\n' "$fremd" >&2
		einordnen "make archiv-welle im Ziel ($kennung)" "$fremd"
		exit 1
	fi
	echo "full-smoke: unbekanntes Ziel ($kennung): make archiv-welle endet laut und nennt den Namen — die Anleitung zeigt auf das Ziel, das das Fragment fuehrt:"
	grep -F -- 'archiv-welle' <<<"$fremd" | sed -n '1p' | sed 's/^/full-smoke:   /'

	# Ein minimaler, GESCHLOSSENER Bestand: Welle-Plan, Ergebnisnotiz und ein Mitglied.
	mkdir -p "$plan_done" "$reviews"
	cat >"$plan_done/$welle.md" <<'SMOKEEOF'
# Welle welle-smoke: E2E der Archivierung

**Verantwortlich:** full-smoke.

## 1. Welle-Ziel

Nur fuer den E2E der Wellen-Archivierung angelegt.
SMOKEEOF
	cat >"$plan_done/$welle-results.md" <<'SMOKEEOF'
# welle-smoke-results: E2E der Archivierung

**Abschluss:** 2026-01-01

## Geliefert

Nur fuer den E2E der Wellen-Archivierung angelegt.
SMOKEEOF
	cat >"$plan_done/slice-999-archiv-smoke.md" <<'SMOKEEOF'
# Slice slice-999: E2E der Archivierung

**Welle:** welle-smoke

## 1. Ziel

Nur fuer den E2E der Wellen-Archivierung angelegt.
SMOKEEOF
	# Zwei Ausloeser, je eine Sperre: ein wellenloser Slice ohne beobachtbare
	# Untergrenze (kein done/*/archiv.zip existiert noch) und ein Review-Report, der
	# bleibt und auf einen verschwindenden zeigt.
	cat >"$plan_done/slice-998-ohne-welle.md" <<'SMOKEEOF'
# Slice slice-998: wellenlos

**Welle:** ohne Welle

## 1. Ziel

Nur fuer den E2E der Wellen-Archivierung angelegt.
SMOKEEOF
	cat >"$reviews/slice-999-review.md" <<'SMOKEEOF'
# Review slice-999

Nur fuer den E2E der Wellen-Archivierung angelegt.
SMOKEEOF
	cat >"$reviews/bleibt.md" <<'SMOKEEOF'
# Review, der bleibt

Er verweist auf [`slice-999-review.md`](slice-999-review.md).
SMOKEEOF
	git -C "$repo" -c user.email=full-smoke@example.invalid -c user.name=full-smoke add -A
	git -C "$repo" -c user.email=full-smoke@example.invalid -c user.name=full-smoke \
		commit -q -m "Archivierungs-Smoke: geschlossene Welle (full-smoke)"
	# Der schreibende Lauf committet SELBST und braucht darum eine Identitaet im Repo:
	# die vier git-Aufrufe des Traegers rufen `git commit` ohne -c.
	git -C "$repo" config user.email full-smoke@example.invalid
	git -C "$repo" config user.name full-smoke

	# (a) DIE ZWEI SPERREN, ueber demselben Aufruf wie (b). Kein Erfolg, nichts
	# geschrieben: die Sperren liegen im Binaer, und der Aufruf erbt sie, statt sie
	# nachzubauen. Der Exit-Code des Traegers kommt durch `make` nicht an — ein
	# fehlgeschlagenes Rezept endet dort immer mit 2.
	local gesperrt="" gesperrt_rc=0 gesperrt_flach="" fehlt="" sperre
	gesperrt="$( make --no-print-directory -C "$repo" archive-welle WELLE="$welle" 2>&1 )" || gesperrt_rc=$?
	gesperrt_flach="$(tr -s '[:space:]' ' ' <<<"$gesperrt")"
	if [ "$gesperrt_rc" -eq 0 ]; then
		echo "full-smoke: FEHLER — $kennung: make archive-welle endet ueber einem Bestand mit zwei Ausloesern mit Exit 0 — die Sperren des Unterkommandos erreichen den Aufruf nicht. Ausgabe:" >&2
		printf '%s\n' "$gesperrt" >&2
		einordnen "make archive-welle ueber zwei Ausloesern ($kennung)" "$gesperrt"
		exit 1
	fi
	for sperre in '[untergrenze]' '[haenger]'; do
		grep -qF -- "$sperre" <<<"$gesperrt_flach" || fehlt="$fehlt [$sperre]"
	done
	if [ -n "$fehlt" ]; then
		echo "full-smoke: FEHLER — $kennung: der gesperrte Lauf nennt nicht jede der zwei Sperren:$fehlt — rot aus falschem Grund? Ausgabe:" >&2
		printf '%s\n' "$gesperrt" >&2
		exit 1
	fi
	if [ -e "$plan_done/$welle" ]; then
		echo "full-smoke: FEHLER — $kennung: der gesperrte Lauf hat trotzdem geschrieben (done/$welle liegt) — die Vorschau steht vor dem Schreibzugriff, und der Lauf hat ihn getan." >&2
		exit 1
	fi
	echo "full-smoke: Sperren erreichen den Aufruf ($kennung): make archive-welle endet ueber zwei Ausloesern nicht erfolgreich, nennt beide und schreibt nichts:"
	grep -oE '\[(untergrenze|haenger)\]' <<<"$gesperrt_flach" | sort -u | sed 's/^/full-smoke:   /'

	# (b) DERSELBE AUFRUF OHNE DIE ZWEI AUSLOESER laeuft real durch.
	git -C "$repo" rm -q -- "$plan_done/slice-998-ohne-welle.md" "$reviews/bleibt.md"
	git -C "$repo" -c user.email=full-smoke@example.invalid -c user.name=full-smoke \
		commit -q -m "Archivierungs-Smoke: die zwei Ausloeser entfernt (full-smoke)"
	local lauf="" lauf_rc=0 lauf_flach=""
	lauf="$( make --no-print-directory -C "$repo" archive-welle WELLE="$welle" 2>&1 )" || lauf_rc=$?
	printf '%s\n' "$lauf"
	lauf_flach="$(tr -s '[:space:]' ' ' <<<"$lauf")"
	if [ "$lauf_rc" -ne 0 ]; then
		echo "full-smoke: FEHLER — $kennung: make archive-welle endet ueber demselben Bestand mit Exit $lauf_rc statt mit 0 — die Archivierung ist im gebootstrappten Repo nicht erreichbar (ADR-0033 Festlegung 4)." >&2
		printf '%s\n' "$lauf" >&2
		einordnen "make archive-welle im Ziel ($kennung)" "$lauf"
		exit 1
	fi
	if ! grep -qF -- "archive-welle ok: $welle" <<<"$lauf_flach"; then
		echo "full-smoke: FEHLER — $kennung: der Lauf meldet den Vollzug nicht (rot aus falschem Grund?). Ausgabe:" >&2
		printf '%s\n' "$lauf" >&2
		exit 1
	fi
	if [ ! -f "$plan_done/$welle/archiv.zip" ]; then
		echo "full-smoke: FEHLER — $kennung: die Archivierung meldet Vollzug, aber $welle/archiv.zip fehlt — der Traeger ist damit nicht gelaufen." >&2
		exit 1
	fi
	local stub
	for stub in "$welle.md" "slice-999-archiv-smoke.md"; do
		if [ ! -f "$plan_done/$welle/$stub" ]; then
			echo "full-smoke: FEHLER — $kennung: kein Stub an der Stelle des bewegten $stub — die Operation laeuft ohne die vendored Vorlage des Ziels (ADR-0033 Festlegung 3)." >&2
			exit 1
		fi
	done
	if [ -e "$reviews/slice-999-review.md" ]; then
		echo "full-smoke: FEHLER — $kennung: der Review-Report des archivierten Slice liegt noch flach in docs/reviews/ — er gehoert ins Archiv." >&2
		exit 1
	fi
	echo "full-smoke: Archivierung im Ziel ($kennung): make archive-welle archiviert real — $welle/archiv.zip mit $welle.md und slice-999-archiv-smoke.md als Stubs, der Review-Report des Slice ist fort."

	# (d) OHNE TRAEGER: Meldung, Exit 0, nichts geschrieben. Der Fall des frischen Klons.
	mv "$carrier" "$carrier.beiseite"
	local ohne="" ohne_rc=0 ohne_flach=""
	ohne="$( make --no-print-directory -C "$repo" archive-welle WELLE=welle-zweit 2>&1 )" || ohne_rc=$?
	mv "$carrier.beiseite" "$carrier"
	ohne_flach="$(tr -s '[:space:]' ' ' <<<"$ohne")"
	if [ "$ohne_rc" -ne 0 ]; then
		echo "full-smoke: FEHLER — $kennung: ohne Traeger endet make archive-welle mit Exit $ohne_rc — ein fehlender Traeger ist kein Fehler des Repos (ADR-0033 Festlegung 4). Ausgabe:" >&2
		printf '%s\n' "$ohne" >&2
		einordnen "make archive-welle ohne Traeger ($kennung)" "$ohne"
		exit 1
	fi
	if ! grep -qF -- "der Traeger liegt nicht" <<<"$ohne_flach"; then
		echo "full-smoke: FEHLER — $kennung: ohne Traeger sagt make archive-welle nicht, was fehlt — die Ausgabe bleibt leer, und der Fall des frischen Klons bleibt unbemerkt. Ausgabe:" >&2
		printf '%s\n' "$ohne" >&2
		exit 1
	fi
	if grep -qF -- "archive-welle ok:" <<<"$ohne_flach"; then
		echo "full-smoke: FEHLER — $kennung: ohne Traeger meldet der Aufruf einen Vollzug — dann lief ein Programm, das es nicht gibt." >&2
		exit 1
	fi
	echo "full-smoke: ohne Traeger ($kennung): make archive-welle meldet den fehlenden Traeger, endet mit 0 und schreibt nichts."
}

archivierung_im_ziel "$tmprepo" "golang"

# slice-032 (LH-FA-06/LH-QA-03): der emittierte Command-Guard muss real greifen —
# nicht nur praesent sein. Wir fuettern ihn mit Hook-JSON: die go-Toolchain (BLOCKED-
# Set --lang go) wird geblockt, ein make-Target durchgelassen. Dieser full-smoke-Schritt
# faehrt zugleich den awk-Pfad (tools/harness/, relativ zu BASH_SOURCE aufgeloest) und
# zeigt, dass Guard + Extraktor mit bash + awk auskommen (kein node/jq). Guard laeuft mit set -e; ein
# Fehler/keine Ausgabe wo Block erwartet wird = rot.
guard="$tmprepo/.claude/hooks/pretooluse-command-guard.sh"
block_out="$(printf '%s' '{"tool_name":"Bash","tool_input":{"command":"go build ./..."}}' | bash "$guard" || true)"
if ! printf '%s' "$block_out" | grep -q '"decision": "block"'; then
	echo "full-smoke: FEHLER — emittierter Guard blockt 'go build' NICHT (BLOCKED-Set/awk-Pfad kaputt? slice-032). Ausgabe: [$block_out]" >&2
	exit 1
fi
pass_out="$(printf '%s' '{"tool_name":"Bash","tool_input":{"command":"make test"}}' | bash "$guard" || true)"
if [ -n "$pass_out" ]; then
	echo "full-smoke: FEHLER — emittierter Guard blockt 'make test' faelschlich (slice-032). Ausgabe: [$pass_out]" >&2
	exit 1
fi
# slice-036: der Guard traegt den universellen Boden GEBACKEN + vereinigt blocked/*. Mit
# --lang go blockt er go (via blocked/go, oben) UND pip (Boden).
pip_out="$(printf '%s' '{"tool_input":{"command":"pip install x"}}' | bash "$guard" || true)"
if ! printf '%s' "$pip_out" | grep -q '"decision": "block"'; then
	echo "full-smoke: FEHLER — emittierter Guard blockt 'pip' NICHT (gebackener Boden kaputt? slice-036). Ausgabe: [$pip_out]" >&2
	exit 1
fi
# FAIL-SAFE (ADR-0007 NEU-H1): der Guard darf NIE fail-open sein. Mit GELEERTEM blocked/
# blockt der gebackene Boden weiter — pip bleibt geblockt, auch ohne jedes Fragment.
rm -f "${tmprepo:?}/tools/harness/blocked/"* 2>/dev/null || true
failsafe_out="$(printf '%s' '{"tool_input":{"command":"pip install x"}}' | bash "$guard" || true)"
if ! printf '%s' "$failsafe_out" | grep -q '"decision": "block"'; then
	echo "full-smoke: FEHLER — Guard blockt pip NICHT mehr nach geleertem blocked/ (fail-OPEN! ADR-0007 NEU-H1). Ausgabe: [$failsafe_out]" >&2
	exit 1
fi

# slice-033 (LH-FA-08): die Workflow-Commands liegen im real gebootstrappten Ziel
# und tragen keine ai-harness-init-interne Referenz (adaptierbar, nicht 1:1 hart).
for rel in implement-slice plan-welle close-welle; do
	if [ ! -f "$tmprepo/.claude/commands/$rel.md" ]; then
		echo "full-smoke: FEHLER — Workflow-Command fehlt: .claude/commands/$rel.md (slice-033)" >&2
		exit 1
	fi
done
if grep -rqE 'ai-harness-init|make mutate|test/mutations' "$tmprepo/.claude/commands/"; then
	echo "full-smoke: FEHLER — emittierter Command traegt ai-harness-init-interne Referenz (slice-033)" >&2
	exit 1
fi

# slice-035 (LH-FA-01/ADR-0007): --lang ist OPTIONAL. Ein SPRACHLOSER Init emittiert die
# Harness + Aggregator + die sprach-agnostischen Fragmente (doc-gate/baseline/enforce) +
# Durchsetzung, OHNE Skelett — `make gates` ist doc-only gruen. Beweis in einem zweiten
# tmp-Repo (der --lang-go-Lauf oben bleibt der One-Shot).
echo "full-smoke: doc-only Bootstrap (OHNE --lang) in ein zweites tmp-Repo ..."
( cd "$tmprepo_doc" && "$tmpbin/ai-harness-init" --name full-smoke-doc )
# slice-097, zweite Variante: die Rollen-Typen sind sprach-agnostisch und UNBEDINGT —
# sie haengen an keinem Laufzeit-Ausgang. Auch hier vor dem Gate-Lauf.
rollen_typen_im_ziel "$tmprepo_doc" "sprachlos"
# slice-098, zweite Variante: die Feldliste beschreibt eine sprach-agnostische Erfassung
# und teilt darum keinen --lang-Zweig. Ein Zahn in nur einer Variante belegte das nicht.
feldliste_im_ziel "$tmprepo_doc" "sprachlos"
git init -q "$tmprepo_doc"
echo "full-smoke: doc-only im Ziel: make -j gates (docs-check + baseline-verify + record-gates, KEIN Code-Gate) ..."
doc_rc=0
doc_out="$( make -j -C "$tmprepo_doc" gates 2>&1 )" || doc_rc=$?
printf '%s\n' "$doc_out"
if [ "$doc_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — sprachloser make gates ist NICHT Exit 0 (doc-only-Gate verletzt, LH-FA-01/slice-035)." >&2
	einordnen "make -j gates im sprachlosen Ziel" "$doc_out"
	exit 1
fi
# Die sprach-agnostischen Checks MUESSEN laufen (docs-check + baseline-verify) ...
doc_missing=""
for marker in "geprüft" "Integritaet + Vollstaendigkeit"; do
	grep -qF -- "$marker" <<<"$doc_out" || doc_missing="$doc_missing [$marker]"
done
if [ -n "$doc_missing" ]; then
	echo "full-smoke: FEHLER — sprachloser make gates ohne Beleg fuer:$doc_missing — stilles Teilmengen-Gate? (LH-QA-01)" >&2
	exit 1
fi
# ... und die Code-Gates (lint/build/test) DUERFEN NICHT laufen (kein halluziniertes
# Code-Gate ohne Sprache): weder ein --target-Aufruf im Output noch ein Skelett am Ziel.
if printf '%s\n' "$doc_out" | grep -qE -- '--target (lint|build|test)'; then
	echo "full-smoke: FEHLER — sprachloser make gates faehrt ein Code-Gate (--target ...) OHNE Sprache (halluziniertes Gate, LH-QA-01)." >&2
	exit 1
fi
for skel in go.mod cmd/app/main.go harness/mk/go.mk Dockerfile; do
	if [ -e "$tmprepo_doc/$skel" ]; then
		echo "full-smoke: FEHLER — sprachloser Init legte ein Skelett-Artefakt an: $skel (soll nur mit --lang, slice-035)." >&2
		exit 1
	fi
done

# slice-036: der SPRACHLOSE emittierte Guard traegt den gebackenen Boden (blockt pip) —
# aber KEIN blocked/go (sprachlos wird kein Fragment emittiert), also blockt er go NICHT.
guard_doc="$tmprepo_doc/.claude/hooks/pretooluse-command-guard.sh"
docpip_out="$(printf '%s' '{"tool_input":{"command":"pip install x"}}' | bash "$guard_doc" || true)"
if ! printf '%s' "$docpip_out" | grep -q '"decision": "block"'; then
	echo "full-smoke: FEHLER — sprachloser Guard blockt 'pip' NICHT (gebackener Boden kaputt? slice-036). Ausgabe: [$docpip_out]" >&2
	exit 1
fi
docgo_out="$(printf '%s' '{"tool_input":{"command":"go build ./..."}}' | bash "$guard_doc" || true)"
if [ -n "$docgo_out" ]; then
	echo "full-smoke: FEHLER — sprachloser Guard blockt 'go' faelschlich (nur der Boden soll greifen, kein blocked/go; slice-036). Ausgabe: [$docgo_out]" >&2
	exit 1
fi
if [ -e "$tmprepo_doc/tools/harness/blocked" ]; then
	echo "full-smoke: FEHLER — sprachloser Init legte tools/harness/blocked/ an (soll nur mit --lang; slice-036)." >&2
	exit 1
fi

# slice-096, zweite Variante: die Erfassung ist SPRACH-AGNOSTISCH — sie beobachtet
# Werkzeug-Aufrufe, und die entstehen auch in einem Ziel ohne Skelett. Dieselbe Pruefung
# wie oben: ein Zahn in nur einer Variante liesse die andere ungemessen.
traeger_im_ziel "$tmprepo_doc" "sprachlos"

# slice-037 (LH-FA-04/ADR-0007): add-lang ergaenzt dem gebootstrappten (hier: sprachlosen)
# Repo ein Sprachmodul WIEDERHOLBAR (Mono-Repo). Zwei Aufrufe (apps/api + apps/web) am
# doc-only-Repo: das geteilte blocked/go wird beim zweiten NICHT als Kollision abgebrochen
# (skip-if-present), beide modul-scoped Code-Gate-Fragmente koexistieren, und `make -j gates`
# faehrt danach ZUSAETZLICH die modul-scoped Go-Gates BEIDER Module (Build-Kontext je <pfad>).
echo "full-smoke: add-lang go apps/api + apps/web ins doc-only-Repo (Mono-Repo, wiederholbar, slice-037) ..."
( cd "$tmprepo_doc" && "$tmpbin/ai-harness-init" add-lang go apps/api )
( cd "$tmprepo_doc" && "$tmpbin/ai-harness-init" add-lang go apps/web )
for rel in apps/api/go.mod apps/api/Dockerfile apps/api/cmd/app/main.go harness/mk/apps-api.mk \
           apps/web/go.mod harness/mk/apps-web.mk tools/harness/blocked/go; do
	if [ ! -e "$tmprepo_doc/$rel" ]; then
		echo "full-smoke: FEHLER — add-lang dropte $rel nicht (Mono-Repo/Wiederholbarkeit kaputt, slice-037)." >&2
		exit 1
	fi
done
addlang_rc=0
addlang_out="$( make -j -C "$tmprepo_doc" gates 2>&1 )" || addlang_rc=$?
printf '%s\n' "$addlang_out"
if [ "$addlang_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — make gates nach add-lang ist NICHT Exit 0 (Mono-Repo-Modul kaputt, slice-037)." >&2
	einordnen "make -j gates nach add-lang go (apps/api + apps/web)" "$addlang_out"
	exit 1
fi
# Beide modul-scoped Go-Gates MUESSEN gelaufen sein: die --target-Echos (Go-Gate lief) UND
# beide Build-Kontexte (apps/api + apps/web) im Recipe-Echo — waere ein Target kollidiert
# (unscoped `test`), liefe nur EIN Modul, ein Kontext fehlte -> hier rot (LH-QA-01,
# Mono-Repo-Kollisionsfreiheit).
addlang_missing=""
for marker in "--target lint" "--target build" "--target test" "apps/api" "apps/web"; do
	grep -qF -- "$marker" <<<"$addlang_out" || addlang_missing="$addlang_missing [$marker]"
done
if [ -n "$addlang_missing" ]; then
	echo "full-smoke: FEHLER — make gates nach add-lang ohne Beleg fuer:$addlang_missing — Modul-Gate/Kollision? (slice-037/LH-QA-01)." >&2
	exit 1
fi
# Der Guard blockt jetzt go (blocked/go via add-lang) — vorher (sprachlos) tat er das nicht.
addlanggo_out="$(printf '%s' '{"tool_input":{"command":"go build ./..."}}' | bash "$guard_doc" || true)"
if ! printf '%s' "$addlanggo_out" | grep -q '"decision": "block"'; then
	echo "full-smoke: FEHLER — Guard blockt 'go' nach add-lang NICHT (blocked/go via add-lang kaputt, slice-037). Ausgabe: [$addlanggo_out]" >&2
	exit 1
fi

# slice-039 (LH-FA-04/ADR-0007): add-lang ergaenzt eine ZWEITE SPRACHE (cpp) DEMSELBEN
# Mono-Repo — gemischte Sprachen koexistieren (go apps/api+apps/web, jetzt cpp apps/engine).
# `add-lang cpp apps/engine` dropt das cpp-Skelett (CMake/Dockerfile/.clang-tidy) + das
# modul-scoped Code-Gate-Fragment + blocked/cpp; danach faehrt `make -j gates` ZUSAETZLICH
# die REALEN C++-Gates (cmake build + ctest + clang-tidy in Docker) — der reale Gate-Lauf
# ist der LH-QA-01-Beweis, dass die C++-Toolchain wirklich lief (kein halluziniertes Gate).
echo "full-smoke: add-lang cpp apps/engine ins Mono-Repo (zweite Sprache, slice-039) ..."
( cd "$tmprepo_doc" && "$tmpbin/ai-harness-init" add-lang cpp apps/engine )
for rel in apps/engine/CMakeLists.txt apps/engine/Dockerfile apps/engine/src/main.cpp \
           apps/engine/.clang-tidy apps/engine/tests/test_main.cpp \
           harness/mk/apps-engine.mk tools/harness/blocked/cpp; do
	if [ ! -e "$tmprepo_doc/$rel" ]; then
		echo "full-smoke: FEHLER — add-lang cpp dropte $rel nicht (zweite Sprache kaputt, slice-039)." >&2
		exit 1
	fi
done
cpp_rc=0
# -Otarget (Output-Sync pro Target): mit dem gemischten Mono-Repo laufen jetzt 9 Docker-
# Builds parallel (6 Go + 3 C++); der lange apt-Lauf des C++-Bildes flutet BuildKit-\r-
# Progress, der ohne Output-Sync die make-Recipe-Echo-Zeilen ANDERER Targets zerhackt
# (der Marker-Grep unten faende die Recipe-Zeile dann nicht). -Otarget puffert je Target
# und gibt sie zusammenhaengend aus — semantik-neutral, nur die Ausgabe-Reihenfolge.
cpp_out="$( make -j -Otarget -C "$tmprepo_doc" gates 2>&1 )" || cpp_rc=$?
printf '%s\n' "$cpp_out"
if [ "$cpp_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — make gates nach add-lang cpp ist NICHT Exit 0 (C++-Gate kaputt, slice-039)." >&2
	einordnen "make -j gates nach add-lang cpp (apps/engine)" "$cpp_out"
	exit 1
fi
# Das cpp-Gate MUSS real gelaufen sein: der modul-scoped Build (apps-engine:test, Kontext
# apps/engine) im Recipe-Echo — waere das Fragment nicht verdrahtet oder ein Target
# kollidiert, liefe es nicht -> hier rot (LH-QA-01, C++ via Docker-Stage).
cpp_missing=""
for marker in "apps/engine" "apps-engine:test"; do
	grep -qF -- "$marker" <<<"$cpp_out" || cpp_missing="$cpp_missing [$marker]"
done
if [ -n "$cpp_missing" ]; then
	echo "full-smoke: FEHLER — make gates nach add-lang cpp ohne Beleg fuer:$cpp_missing — C++-Gate lief nicht? (slice-039/LH-QA-01)." >&2
	exit 1
fi
# Der Guard blockt jetzt eine C++-Host-Toolchain (blocked/cpp via add-lang) — cmake geblockt.
cppguard_out="$(printf '%s' '{"tool_input":{"command":"cmake -B build"}}' | bash "$guard_doc" || true)"
if ! printf '%s' "$cppguard_out" | grep -q '"decision": "block"'; then
	echo "full-smoke: FEHLER — Guard blockt 'cmake' nach add-lang cpp NICHT (blocked/cpp kaputt, slice-039). Ausgabe: [$cppguard_out]" >&2
	exit 1
fi

# slice-045b (LH-FA-04 Arch-Achse / ADR-0009): add-lang go apps/hex --arch hexslice dropt
# das GESCHICHTETE hexSlice-Skelett (domain/application/ports/adapters + cmd), und `make -j
# gates` faehrt danach das modul-scoped Go-Gate von apps/hex REAL — d. h. es UEBERSETZT und
# LINTET den generierten hexSlice-Code in Docker (build+lint+test-Stages). Das ist der
# end-to-end-Beweis, den der slice-045a-Compile-Test (nur go test) NICHT abdeckt: der
# emittierte .golangci.yml-Lint auf dem Schichten-Code. Ein flaches Modul (--arch flat)
# traegt hier KEINE hexagon-Schicht — die Achse wirkt.
echo "full-smoke: add-lang go apps/hex --arch hexslice ins Mono-Repo (Arch-Achse, slice-045b) ..."
# ERSTES --arch-MODUL und damit die erste Anfrage nach dem a-check-Bild: das Werkzeug
# erzeugt das Arch-Gate-Fragment aus dessen --print-mk-Ausgabe. Auf einem frischen
# Laeufer liegt das Bild nicht lokal.
hexadd_rc=0
hexadd_out="$( cd "$tmprepo_doc" && "$tmpbin/ai-harness-init" add-lang go apps/hex --arch hexslice 2>&1 )" || hexadd_rc=$?
printf '%s\n' "$hexadd_out"
if [ "$hexadd_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — add-lang go apps/hex --arch hexslice ist NICHT Exit 0 (Exit $hexadd_rc)." >&2
	einordnen "add-lang --arch hexslice (das Werkzeug holt a-check fuer --print-mk)" "$hexadd_out"
	exit 1
fi
for rel in apps/hex/internal/hexagon/domain/example/greeting.go \
           apps/hex/internal/hexagon/application/example/greet/handler.go \
           apps/hex/internal/adapters/inbound/cli/example/cli.go \
           apps/hex/cmd/app/main.go harness/mk/apps-hex.mk; do
	if [ ! -e "$tmprepo_doc/$rel" ]; then
		echo "full-smoke: FEHLER — add-lang --arch hexslice dropte $rel nicht (Arch-Achse kaputt, slice-045b)." >&2
		exit 1
	fi
done
# slice-053: die Zusage "nicht getragene Kombination -> Exit 2" ist GEWANDERT, nicht
# entfallen. Bis slice-053 trug sie `cpp --arch hexslice`; seit der cpp-Renderer hexslice
# rendert, ist eine UNBEKANNTE Architektur der verbliebene reale Ablehnungs-Fall. Es darf
# NICHT still ein Geruestung-only-Modul entstehen (slice-045a-Review INFO-1).
onion_rc=0
( cd "$tmprepo_doc" && "$tmpbin/ai-harness-init" add-lang cpp apps/onion --arch onion ) || onion_rc=$?
if [ "$onion_rc" -ne 2 ]; then
	echo "full-smoke: FEHLER — add-lang cpp --arch onion rc=$onion_rc, want 2 (Arch-Validierung kaputt, slice-053)." >&2
	exit 1
fi
if [ -e "$tmprepo_doc/apps/onion/CMakeLists.txt" ]; then
	echo "full-smoke: FEHLER — unbekannte Architektur legte ein Geruestung-Artefakt an (still statt Exit 2)." >&2
	exit 1
fi
hex_rc=0
hex_out="$( make -j -Otarget -C "$tmprepo_doc" gates 2>&1 )" || hex_rc=$?
printf '%s\n' "$hex_out"
if [ "$hex_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — make gates nach add-lang --arch hexslice ist NICHT Exit 0 (hexSlice-Code uebersetzt/lintet nicht, slice-045b)." >&2
	einordnen "make -j gates nach add-lang go --arch hexslice (apps/hex)" "$hex_out"
	exit 1
fi
hex_missing=""
for marker in "apps/hex" "apps-hex:build" "apps-hex:lint"; do
	grep -qF -- "$marker" <<<"$hex_out" || hex_missing="$hex_missing [$marker]"
done
if [ -n "$hex_missing" ]; then
	echo "full-smoke: FEHLER — make gates nach --arch hexslice ohne Beleg fuer:$hex_missing — hexSlice-Gate (build/lint) lief nicht? (slice-045b/LH-QA-01)." >&2
	exit 1
fi

# slice-046 (LH-FA-07/ADR-0009): das hexSlice-Modul traegt sein ARCHITEKTUR-GATE — die
# Schicht-Config IM MODUL, das tool-generierte a-check.mk im Ziel-Root und das
# modul-scoped Gate-Fragment. Der Lauf oben hat es bereits mitgefahren; hier der Beleg,
# dass es (a) liegt, (b) im zusammengefuehrten `make gates` WIRKLICH lief.
for rel in apps/hex/.a-check.yml a-check.mk harness/mk/arch-apps-hex.mk; do
	if [ ! -e "$tmprepo_doc/$rel" ]; then
		echo "full-smoke: FEHLER — hexSlice-Modul ohne Arch-Gate-Artefakt: $rel (slice-046/LH-FA-07)." >&2
		exit 1
	fi
done
# Der Beleg ist der MOUNT des Moduls im Recipe-Echo, nicht der Target-NAME: make echot die
# Recipe-Zeile, und die traegt den Namen `a-check-apps-hex` nirgends (anders als die
# Go-Gates, deren Recipe `-t apps-hex:lint` enthaelt). `apps/hex":/src:ro` ist die
# a-check-Mount-Form (d-check mountet nach /repo) und damit eindeutig.
if ! grep -qF -- 'apps/hex":/src:ro' <<<"$hex_out"; then
	echo "full-smoke: FEHLER — make gates fuhr das Arch-Gate NICHT mit (kein a-check-Mount von apps/hex im Lauf; slice-046/LH-QA-01)." >&2
	exit 1
fi
# LH-QA-01 andersherum: die FLACHEN Module derselben Mono-Repo-Ziele bekommen KEIN
# Arch-Gate — kein Fragment, keine Config. Ein Gate ueber flachem (leerem) Pruefbereich
# waere genau der halluzinierte Gate, den die Welle ausschliesst.
for rel in harness/mk/arch-apps-api.mk harness/mk/arch-apps-web.mk apps/api/.a-check.yml .a-check.yml; do
	if [ -e "$tmprepo_doc/$rel" ]; then
		echo "full-smoke: FEHLER — flaches Modul bekam ein Arch-Gate-Artefakt: $rel (halluziniertes Gate, LH-QA-01/slice-046)." >&2
		exit 1
	fi
done
if [ -e "$tmprepo/a-check.mk" ] || [ -e "$tmprepo/.a-check.yml" ]; then
	echo "full-smoke: FEHLER — das FLACHE --lang-go-Ziel traegt ein Arch-Gate-Artefakt (LH-QA-01/slice-046)." >&2
	exit 1
fi

# ZAEHNE (AGENTS.md §3.6): ein gruen laufendes Gate belegt nicht, dass es greift. Ein
# verbotener Import (Domain -> Adapter, gegen die inward-only-Kanten) MUSS das emittierte
# Gate roetten. Danach zuruecknehmen — der Rest des Smokes laeuft auf dem heilen Stand.
hexdomain="$tmprepo_doc/apps/hex/internal/hexagon/domain/example/greeting.go"
cp "$hexdomain" "$hexdomain.orig"
# Import in die Adapter-Schicht einschmuggeln (blank import: kompiliert, verletzt aber die
# Richtung) — der sed haengt ihn an die vorhandene errors-Import-Zeile.
sed -i 's|^import "errors"$|import (\n\t"errors"\n\n\t_ "app/internal/adapters/outbound/notify"\n)|' "$hexdomain"
teeth_rc=0
teeth_out="$( make -C "$tmprepo_doc" a-check-apps-hex 2>&1 )" || teeth_rc=$?
mv "$hexdomain.orig" "$hexdomain"
if [ "$teeth_rc" -eq 0 ]; then
	echo "full-smoke: FEHLER — das emittierte Arch-Gate bleibt bei einem VERBOTENEN Import gruen (zahnloses Gate, AGENTS.md §3.6/LH-QA-01)." >&2
	printf '%s\n' "$teeth_out" >&2
	exit 1
fi
if ! grep -qE 'core-impurity|wrong-direction' <<<"$teeth_out"; then
	echo "full-smoke: FEHLER — Arch-Gate rot, aber ohne Richtungs-Befund (rot aus falschem Grund? slice-046). Ausgabe:" >&2
	printf '%s\n' "$teeth_out" >&2
	einordnen "make a-check-apps-hex (Arch-Gate-Zahn, go)" "$teeth_out"
	exit 1
fi
echo "full-smoke: Arch-Gate-Zaehne belegt (verbotener Domain->Adapter-Import faerbt a-check rot, danach zurueckgenommen):"
# Den Befund SICHTBAR machen: ein „belegt"-Satz ohne die Zeile, die ihn belegt, ist
# genau die Behauptung ohne Beleg, die AGENTS.md §3.6 meint. Der Lauf-Output steht
# sonst nur im Erfolgsfall-Puffer und wuerde nie gedruckt.
# KEIN `| head -N`: head schliesst die Pipe nach N Zeilen, der Producer bekommt SIGPIPE,
# und unter `set -e` + pipefail bricht full-smoke daran ab — ohne Meldung, groessen-
# abhaengig. Dieselbe Klasse wie F-5 (die zweite Instanz im selben Slice, Review-Runde 2
# N-1). `sed -n 1,2p` liest weiter und drainiert, statt frueh zu schliessen.
grep -E 'core-impurity|wrong-direction' <<<"$teeth_out" | sed -n '1,2s/^/full-smoke:   /p'

# --- slice-053 (LH-FA-04 Arch-Achse, zweite Sprache): cpp x hexslice ---------------
# Bis hierher trug NUR go das Schicht-Layout. Jetzt dasselbe fuer C++ — und zwar mit den
# beiden Belegen, die der Slice verlangt: (a) das Modul wird real GEBAUT (nicht nur
# abgelegt), (b) der Build sieht die SCHICHTEN. (b) ist nicht selbstverstaendlich: die
# arch-invariante CMakeLists uebersetzt genau eine Uebersetzungseinheit (src/main.cpp),
# und eine Schicht-Datei, die keine erreicht, waere still tot bei gruenem Gate (die
# slice-024-Klasse "gruen ueber einer Teilmenge").
echo "full-smoke: add-lang cpp apps/cpphex --arch hexslice (Arch-Achse, zweite Sprache, slice-053) ..."
( cd "$tmprepo_doc" && "$tmpbin/ai-harness-init" add-lang cpp apps/cpphex --arch hexslice )
for rel in apps/cpphex/src/hexagon/domain/example/greeting.hpp \
           apps/cpphex/src/hexagon/application/example/greet/handler.hpp \
           apps/cpphex/src/hexagon/application/example/ports/greeting_repository.hpp \
           apps/cpphex/src/adapters/outbound/memory/example/repository.hpp \
           apps/cpphex/src/main.cpp apps/cpphex/tests/test_greet.cpp \
           apps/cpphex/.a-check.yml harness/mk/apps-cpphex.mk harness/mk/arch-apps-cpphex.mk; do
	if [ ! -e "$tmprepo_doc/$rel" ]; then
		echo "full-smoke: FEHLER — add-lang cpp --arch hexslice dropte $rel nicht (slice-053)." >&2
		exit 1
	fi
done
cpphex_rc=0
cpphex_out="$( make -j -Otarget -C "$tmprepo_doc" gates 2>&1 )" || cpphex_rc=$?
printf '%s\n' "$cpphex_out"
if [ "$cpphex_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — make gates nach add-lang cpp --arch hexslice ist NICHT Exit 0 (C++-hexSlice uebersetzt/lintet nicht, slice-053)." >&2
	einordnen "make -j gates nach add-lang cpp --arch hexslice (apps/cpphex)" "$cpphex_out"
	exit 1
fi
cpphex_missing=""
for marker in "apps-cpphex:build" "apps-cpphex:lint" 'apps/cpphex":/src:ro'; do
	grep -qF -- "$marker" <<<"$cpphex_out" || cpphex_missing="$cpphex_missing [$marker]"
done
if [ -n "$cpphex_missing" ]; then
	echo "full-smoke: FEHLER — make gates ohne Beleg fuer:$cpphex_missing — C++-hexSlice-Gate oder sein Arch-Gate lief nicht? (slice-053/LH-QA-01)." >&2
	exit 1
fi
# ZAEHNE (AGENTS.md §3.6), Teil 1 — "der Build sieht die Schichten": ein Syntaxfehler in
# einem SCHICHT-Header MUSS den Modul-Build roetten. Bliebe er gruen, waere die Schicht
# nicht uebersetzt worden und das ganze Layout tote Ablage. Danach zuruecknehmen.
cpplayer="$tmprepo_doc/apps/cpphex/src/hexagon/domain/example/greeting.hpp"
cp "$cpplayer" "$cpplayer.orig"
printf '%s\n' 'static_assert(false, "full-smoke: absichtlicher Schicht-Fehler");' >> "$cpplayer"
cppteeth_rc=0
cppteeth_out="$( make -C "$tmprepo_doc" build-apps-cpphex 2>&1 )" || cppteeth_rc=$?
mv "$cpplayer.orig" "$cpplayer"
if [ "$cppteeth_rc" -eq 0 ]; then
	echo "full-smoke: FEHLER — ein Fehler in der Domain-SCHICHT laesst den C++-Build gruen: die Schichten werden nicht uebersetzt (tote Ablage, slice-024-Klasse/AGENTS.md §3.6)." >&2
	printf '%s\n' "$cppteeth_out" >&2
	exit 1
fi
if ! grep -qF -- 'full-smoke: absichtlicher Schicht-Fehler' <<<"$cppteeth_out"; then
	echo "full-smoke: FEHLER — C++-Build rot, aber nicht wegen der Schicht-Datei (rot aus falschem Grund?). Ausgabe:" >&2
	printf '%s\n' "$cppteeth_out" >&2
	einordnen "make build-apps-cpphex (C++-Schicht-Zahn)" "$cppteeth_out"
	exit 1
fi
echo "full-smoke: C++-Schicht-Zaehne belegt (Fehler in der Domain-Schicht faerbt den Modul-Build rot, danach zurueckgenommen):"
grep -F -- 'full-smoke: absichtlicher Schicht-Fehler' <<<"$cppteeth_out" | sed -n '1,2s/^/full-smoke:   /p'

# ZAEHNE, Teil 2 — "der LINT sieht die Schichten": ein Build-Fehler beweist nur, dass der
# Compiler sie erreicht. clang-tidy laeuft nur auf src/main.cpp; ob es die eingebundenen
# Schicht-Header mitprueft, entscheidet der HeaderFilterRegex — und ein am Zeilenanfang
# verankertes Muster traefe den absoluten Container-Pfad NIE (gemessen: der Gate blieb
# gruen). Also messen statt behaupten: ein bugprone-Verstoss IN der Domain-Schicht muss
# den Lint-Gate roetten.
cpplint_layer="$tmprepo_doc/apps/cpphex/src/hexagon/domain/example/greeting.hpp"
cp "$cpplint_layer" "$cpplint_layer.orig"
# if/else mit identischen Zweigen -> bugprone-branch-clone; die Datei bleibt UEBERSETZBAR,
# der Befund kommt also wirklich vom Linter und nicht vom Compiler. Eingefuegt vor der
# schliessenden Namensraum-Zeile — reines sed, kein python/jq (LH-QA-03: das Repo kommt
# mit bash + git + docker aus).
sed -i 's|^}  // namespace hexagon::domain::example$|inline bool full_smoke_probe(bool b) { if (b) { return true; } else { return true; } }\n\n}  // namespace hexagon::domain::example|' "$cpplint_layer"
cpplint_rc=0
cpplint_out="$( make -C "$tmprepo_doc" lint-apps-cpphex 2>&1 )" || cpplint_rc=$?
mv "$cpplint_layer.orig" "$cpplint_layer"
if [ "$cpplint_rc" -eq 0 ]; then
	echo "full-smoke: FEHLER — ein clang-tidy-Verstoss IN der Domain-Schicht laesst den Lint-Gate gruen: die Schicht-Header werden nicht gelintet (HeaderFilterRegex? AGENTS.md §3.6/LH-QA-01)." >&2
	printf '%s\n' "$cpplint_out" >&2
	exit 1
fi
if ! grep -qF -- 'bugprone-branch-clone' <<<"$cpplint_out"; then
	echo "full-smoke: FEHLER — Lint-Gate rot, aber ohne den erwarteten Schicht-Befund (rot aus falschem Grund?). Ausgabe:" >&2
	printf '%s\n' "$cpplint_out" >&2
	einordnen "make lint-apps-cpphex (C++-Lint-Zahn)" "$cpplint_out"
	exit 1
fi
echo "full-smoke: C++-Lint-Zaehne belegt (bugprone-Verstoss in der Domain-Schicht faerbt den Lint-Gate rot, danach zurueckgenommen):"
grep -F -- 'bugprone-branch-clone' <<<"$cpplint_out" | sed -n '1,2s/^/full-smoke:   /p'

# ZAEHNE, Teil 3 (slice-054) — "das ARCH-GATE sieht die Schichten": Build und Lint sagen
# nichts ueber die Schicht-RICHTUNG. Ein verbotener domain -> adapters Include muss das
# emittierte a-check-Gate roetten, und zwar MIT Richtungs-Befund: ein Include kann auch
# den Compiler roeten (fehlende Datei, Zyklus) — dann waere der Zahn rot aus falschem
# Grund. Dieselbe Form, die welle-07 fuer Go etabliert hat.
cpparch_layer="$tmprepo_doc/apps/cpphex/src/hexagon/domain/example/greeting.hpp"
cp "$cpparch_layer" "$cpparch_layer.orig"
# Der Include steht modul-root-relativ — nur diese Form loest a-check auf (slice-053).
sed -i '1i #include "src/adapters/outbound/notify/stdout.hpp"' "$cpparch_layer"
cpparch_rc=0
cpparch_out="$( make -C "$tmprepo_doc" a-check-apps-cpphex 2>&1 )" || cpparch_rc=$?
mv "$cpparch_layer.orig" "$cpparch_layer"
if [ "$cpparch_rc" -eq 0 ]; then
	echo "full-smoke: FEHLER — das emittierte cpp-Arch-Gate bleibt bei einem VERBOTENEN Import gruen (zahnloses Gate, AGENTS.md §3.6/LH-QA-01)." >&2
	printf '%s\n' "$cpparch_out" >&2
	exit 1
fi
if ! grep -qE 'core-impurity|wrong-direction' <<<"$cpparch_out"; then
	echo "full-smoke: FEHLER — cpp-Arch-Gate rot, aber ohne Richtungs-Befund (rot aus falschem Grund? slice-054). Ausgabe:" >&2
	printf '%s\n' "$cpparch_out" >&2
	einordnen "make a-check-apps-cpphex (Arch-Gate-Zahn, cpp)" "$cpparch_out"
	exit 1
fi
echo "full-smoke: C++-Arch-Gate-Zaehne belegt (verbotener Domain->Adapter-Include faerbt a-check rot, danach zurueckgenommen):"
grep -E 'core-impurity|wrong-direction' <<<"$cpparch_out" | sed -n '1,2s/^/full-smoke:   /p'

# slice-046, ROOT-Modul: der Init-One-Shot `--lang go --arch hexslice` verortet das Modul
# am Repo-Root — das Arch-Gate mountet dann das GANZE Ziel, samt der vendored Baseline.
# Genau hier schlug der 0700-Modus des <tag>-Verzeichnisses zu (a-check laeuft als
# Nicht-Root und kann es nicht traversieren -> Exit 2 „permission denied"). Der Fall ist
# eigenstaendig zu belegen; die Mono-Repo-Module oben mounten nur ihr Unterverzeichnis.
echo "full-smoke: Root-Modul-Bootstrap (--lang go --arch hexslice) in ein viertes tmp-Repo (slice-046) ..."
( cd "$tmprepo_hex" && "$tmpbin/ai-harness-init" --lang go --arch hexslice --name full-smoke-hex )
git init -q "$tmprepo_hex"
for rel in .a-check.yml a-check.mk harness/mk/arch-go.mk internal/hexagon/domain/example/greeting.go; do
	if [ ! -e "$tmprepo_hex/$rel" ]; then
		echo "full-smoke: FEHLER — Root-Modul (--arch hexslice) ohne $rel (slice-046)." >&2
		exit 1
	fi
done
roothex_rc=0
roothex_out="$( make -C "$tmprepo_hex" a-check 2>&1 )" || roothex_rc=$?
printf '%s\n' "$roothex_out"
if [ "$roothex_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — make a-check am Root-Modul ist NICHT Exit 0 (Schicht-Config falsch verortet oder Baseline-Verzeichnis nicht traversierbar? slice-046/LH-FA-07)." >&2
	einordnen "make a-check am go-Root-Modul" "$roothex_out"
	exit 1
fi
# Das Gate haengt auch WIRKLICH im Aggregator (nicht nur als Einzel-Target erreichbar):
# `make -n gates` zeigt die Recipes, ohne sie zu fahren. Erst in eine Variable, dann
# Here-String — NICHT `make -n … | grep -q`: unter pipefail schliesst grep beim ersten
# Treffer die Pipe, make bekommt EPIPE und pipefail propagiert dessen Nonzero (dieselbe
# Klasse, gegen die der Kopf dieses Skripts steuert; Review F-5). Der Marker ist die
# a-check-MOUNT-Form, nicht das blosse Wort "a-check" — letzteres steht auch in einem
# Kommentar oder Dateinamen (Verifier-LOW: unspezifischer Marker).
# `|| dryrun_rc=$?` statt nackter Zuweisung: sonst beendet `set -e` den Smoke ohne jede
# Diagnose, weil die make-Meldung in der verworfenen Variablen steckt (Runde 2, N-4).
dryrun_rc=0
dryrun_out="$( make -n -C "$tmprepo_hex" gates 2>&1 )" || dryrun_rc=$?
if [ "$dryrun_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — make -n gates am Root-Modul scheiterte (rc=$dryrun_rc):" >&2
	printf '%s\n' "$dryrun_out" >&2
	exit 1
fi
if ! grep -qF -- ':/src:ro' <<<"$dryrun_out"; then
	echo "full-smoke: FEHLER — das Root-Arch-Gate haengt nicht in make gates (GATE_CHECKS-Verdrahtung, slice-046)." >&2
	exit 1
fi

# slice-054 (Review-F-5 aus slice-053): der Root-One-Shot fuer C++. Am Repo-Root ist
# CMAKE_SOURCE_DIR der REPO-Root und nicht ein Modul-Verzeichnis — die modul-root-relativen
# Schicht-Includes muessen sich also gegen einen anderen Basis-Pfad aufloesen als im
# Mono-Repo-Fall. Der Pfad war plausibel korrekt und ungeprueft — dieser Block prueft ihn.
echo "full-smoke: Root-Modul-Bootstrap (--lang cpp --arch hexslice) in ein fuenftes tmp-Repo (slice-054) ..."
( cd "$tmprepo_cpphex" && "$tmpbin/ai-harness-init" --lang cpp --arch hexslice --name full-smoke-cpphex )
git init -q "$tmprepo_cpphex"
for rel in .a-check.yml a-check.mk harness/mk/arch-cpp.mk src/hexagon/domain/example/greeting.hpp src/main.cpp; do
	if [ ! -e "$tmprepo_cpphex/$rel" ]; then
		echo "full-smoke: FEHLER — cpp-Root-Modul (--arch hexslice) ohne $rel (slice-054)." >&2
		exit 1
	fi
done
cpproot_rc=0
cpproot_out="$( make -j -Otarget -C "$tmprepo_cpphex" gates 2>&1 )" || cpproot_rc=$?
printf '%s\n' "$cpproot_out"
if [ "$cpproot_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — make gates am cpp-Root-Modul ist NICHT Exit 0 (Include-Pfad am Root? Schicht-Config falsch verortet? slice-054)." >&2
	einordnen "make -j gates am cpp-Root-Modul" "$cpproot_out"
	exit 1
fi
# Das Arch-Gate muss im Lauf WIRKLICH vorgekommen sein — der Mount ist der Beleg, nicht
# das blosse Wort a-check (das steht auch in Kommentaren und Dateinamen).
if ! grep -qF -- ':/src:ro' <<<"$cpproot_out"; then
	echo "full-smoke: FEHLER — am cpp-Root-Modul lief das Arch-Gate nicht mit (GATE_CHECKS-Verdrahtung, slice-054)." >&2
	exit 1
fi
# Review F-1 / Verifier R-1, BEHAVIORAL: mit gesetztem A_CHECK_IMAGE (dem dokumentierten
# Adopter-Override) muss das Gate WEITER existieren und laufen. Keyte der include-once-
# Waechter auf diese Variable, entfiele der `include` und `GATE_CHECKS += a-check` zeigte
# auf ein undefiniertes Target ("No rule to make target 'a-check'"). Der Override traegt
# hier dieselbe Referenz, die der Bootstrap gepinnt hat — geprueft wird die Verdrahtung,
# nicht ein anderes Image.
override_ref="$( sed -n 's/^A_CHECK_IMAGE ?= //p' "$tmprepo_hex/a-check.mk" )"
if [ -z "$override_ref" ]; then
	echo "full-smoke: FEHLER — im emittierten a-check.mk steht kein A_CHECK_IMAGE-Pin (slice-046/LH-QA-02)." >&2
	exit 1
fi
override_rc=0
override_out="$( A_CHECK_IMAGE="$override_ref" make -C "$tmprepo_hex" a-check 2>&1 )" || override_rc=$?
if [ "$override_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — mit gesetztem A_CHECK_IMAGE ist das Arch-Gate weg oder rot (keyt der include-once-Waechter auf den Adopter-Override? Review F-1). rc=$override_rc" >&2
	printf '%s\n' "$override_out" >&2
	einordnen "make a-check mit gesetztem A_CHECK_IMAGE" "$override_out"
	exit 1
fi

# slice-046 (Review F-2): ZWEI hexSlice-Module in einem Mono-Repo. Jedes bringt sein
# Arch-Gate-Fragment mit, und jedes Fragment will `include a-check.mk`. Ohne den
# include-once-Waechter definierte der zweite `include` dieselben Targets erneut — make
# meldet "overriding recipe" und das Verhalten haengt an der Include-Reihenfolge. Der
# Waechter war bis hierhin nur als Literal getestet; DIES ist sein Verhaltens-Beleg.
echo "full-smoke: zweites hexSlice-Modul (apps/hex2) ins Mono-Repo — include-once + Koexistenz (slice-046) ..."
( cd "$tmprepo_doc" && "$tmpbin/ai-harness-init" add-lang go apps/hex2 --arch hexslice )
for rel in apps/hex2/.a-check.yml harness/mk/arch-apps-hex2.mk; do
	if [ ! -e "$tmprepo_doc/$rel" ]; then
		echo "full-smoke: FEHLER — zweites hexSlice-Modul ohne $rel (slice-046)." >&2
		exit 1
	fi
done
two_rc=0
two_out="$( make -j -Otarget -C "$tmprepo_doc" gates 2>&1 )" || two_rc=$?
if [ "$two_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — make gates mit ZWEI hexSlice-Modulen ist NICHT Exit 0 (doppelter include? slice-046/Review F-2). rc=$two_rc" >&2
	printf '%s\n' "$two_out" >&2
	einordnen "make -j gates mit zwei hexSlice-Modulen" "$two_out"
	exit 1
fi
if grep -qF -- "overriding recipe" <<<"$two_out"; then
	echo "full-smoke: FEHLER — make meldet 'overriding recipe': a-check.mk wurde doppelt eingebunden (include-once-Waechter kaputt, Review F-2)." >&2
	exit 1
fi
two_missing=""
for marker in 'apps/hex":/src:ro' 'apps/hex2":/src:ro'; do
	grep -qF -- "$marker" <<<"$two_out" || two_missing="$two_missing [$marker]"
done
if [ -n "$two_missing" ]; then
	echo "full-smoke: FEHLER — mit zwei hexSlice-Modulen fehlt der Gate-Lauf fuer:$two_missing (ein Modul stillgelegt? slice-046/LH-QA-01)." >&2
	exit 1
fi
# Beide Mount-Zeilen SICHTBAR machen: die Assertion oben lebt im Puffer, und ein
# „beide liefen"-Satz ohne die zwei Zeilen ist eine Behauptung ohne Beleg (dieselbe
# Sichtbarkeits-Disziplin wie beim Zaehne-Beweis).
echo "full-smoke: beide Arch-Gates liefen im selben make-gates-Lauf:"
grep -oE 'apps/hex2?":/src:ro' <<<"$two_out" | sort -u | sed 's/^/full-smoke:   /'

# --- slice-058 (LH-FA-04 Arch-Achse / ADR-0010): go x hexagonal, das DRITTE Layout -----
# Nicht „hexslice mit weniger Regeln", sondern ein eigenes Layout mit eigenem Vokabular
# (core/port/adapter statt domain/application/ports/adapters). Belegt werden hier drei
# Dinge, die kein Unit-Test belegen kann: (a) das Modul entsteht mit den Pfaden der
# gelebten Familien-Konvention und NICHT mit dem `--print-config`-Geruest, (b) `make -j
# gates` UEBERSETZT und LINTET den Schichten-Code real, (c) die beiden TRAGENDEN Regeln
# dieses Layouts haben Zaehne — mit Regel-NAMEN, nicht nur Exit != 0.
echo "full-smoke: add-lang go apps/hexagonal --arch hexagonal (drittes Layout, slice-058/ADR-0010) ..."
( cd "$tmprepo_doc" && "$tmpbin/ai-harness-init" add-lang go apps/hexagonal --arch hexagonal )
for rel in apps/hexagonal/internal/hexagon/core/greet.go \
           apps/hexagonal/internal/hexagon/core/greeting.go \
           apps/hexagonal/internal/hexagon/port/greeting_repository.go \
           apps/hexagonal/internal/adapter/driven/memory/repository.go \
           apps/hexagonal/internal/adapter/driving/cli/cli.go \
           apps/hexagonal/cmd/app/main.go \
           apps/hexagonal/.a-check.yml harness/mk/apps-hexagonal.mk harness/mk/arch-apps-hexagonal.mk; do
	if [ ! -e "$tmprepo_doc/$rel" ]; then
		echo "full-smoke: FEHLER — add-lang --arch hexagonal dropte $rel nicht (slice-058/ADR-0010 Festlegung 1)." >&2
		exit 1
	fi
done
# ADR-0010 Festlegung 1, andersherum: emittiert wird die FAMILIEN-Konvention, nicht das
# `a-check --print-config`-Geruest. Entstuende dessen Form, waere die Entscheidung still
# gedreht — und niemand saehe es, weil beide Formen gruen durchs Gate gehen.
for rel in apps/hexagonal/internal/core apps/hexagonal/internal/ports apps/hexagonal/internal/adapters; do
	if [ -e "$tmprepo_doc/$rel" ]; then
		echo "full-smoke: FEHLER — hexagonal emittierte das --print-config-Geruest ($rel) statt der Familien-Konvention (ADR-0010 Festlegung 1)." >&2
		exit 1
	fi
done
# Zweite Stufe der Arch-Validierung, seit slice-058 wieder ERREICHBAR: hexagonal ist ein
# gueltiger Achsen-Wert, den der cpp-Renderer nicht traegt -> Exit 2, kein Artefakt
# (zwischen slice-053 und slice-058 war dieser Pfad von aussen nicht erreichbar).
cpphexagonal_rc=0
( cd "$tmprepo_doc" && "$tmpbin/ai-harness-init" add-lang cpp apps/cpphexagonal --arch hexagonal ) || cpphexagonal_rc=$?
if [ "$cpphexagonal_rc" -ne 2 ]; then
	echo "full-smoke: FEHLER — add-lang cpp --arch hexagonal rc=$cpphexagonal_rc, want 2 (sprach-spezifische Arch-Validierung kaputt, slice-058)." >&2
	exit 1
fi
if [ -e "$tmprepo_doc/apps/cpphexagonal/CMakeLists.txt" ]; then
	echo "full-smoke: FEHLER — die nicht getragene Kombination legte ein Geruestung-Artefakt an (still statt Exit 2)." >&2
	exit 1
fi
hexagonal_rc=0
hexagonal_out="$( make -j -Otarget -C "$tmprepo_doc" gates 2>&1 )" || hexagonal_rc=$?
if [ "$hexagonal_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — make gates mit dem hexagonalen Modul ist NICHT Exit 0 (Schichten-Code uebersetzt/lintet nicht, slice-058)." >&2
	printf '%s\n' "$hexagonal_out" >&2
	einordnen "make -j gates mit dem hexagonalen Modul (apps/hexagonal)" "$hexagonal_out"
	exit 1
fi
hexagonal_missing=""
for marker in "apps-hexagonal:build" "apps-hexagonal:lint" 'apps/hexagonal":/src:ro'; do
	grep -qF -- "$marker" <<<"$hexagonal_out" || hexagonal_missing="$hexagonal_missing [$marker]"
done
if [ -n "$hexagonal_missing" ]; then
	echo "full-smoke: FEHLER — make gates ohne Beleg fuer:$hexagonal_missing — Code-Gate oder Arch-Gate des hexagonalen Moduls lief nicht? (slice-058/LH-QA-01)." >&2
	exit 1
fi

# ZAHN 1 (ADR-0010 Fitness-Function): der Kern traegt `role: app` und darf KEINEN Adapter
# sehen. Ein Import core -> driven muss als `app-impurity` rot werden — mit dem
# Regel-NAMEN, sonst waere „rot" auch aus einem Compile-Fehler erklaerbar.
hexcore="$tmprepo_doc/apps/hexagonal/internal/hexagon/core/greeting.go"
cp "$hexcore" "$hexcore.orig"
sed -i 's|^import "errors"$|import (\n\t"errors"\n\n\t_ "app/internal/adapter/driven/memory"\n)|' "$hexcore"
impurity_rc=0
impurity_out="$( make -C "$tmprepo_doc" a-check-apps-hexagonal 2>&1 )" || impurity_rc=$?
mv "$hexcore.orig" "$hexcore"
if [ "$impurity_rc" -eq 0 ]; then
	echo "full-smoke: FEHLER — core -> driven laesst das Arch-Gate GRUEN (zahnloses Gate, AGENTS.md 3.6/LH-QA-01)." >&2
	printf '%s\n' "$impurity_out" >&2
	exit 1
fi
if ! grep -qF -- 'app-impurity' <<<"$impurity_out"; then
	echo "full-smoke: FEHLER — Arch-Gate rot, aber NICHT als app-impurity (rot aus falschem Grund; traegt der Kern noch role: app? ADR-0010). Ausgabe:" >&2
	printf '%s\n' "$impurity_out" >&2
	einordnen "make a-check-apps-hexagonal (Zahn 1, app-impurity)" "$impurity_out"
	exit 1
fi
echo "full-smoke: hexagonal-Zahn 1 belegt (core -> driven faerbt a-check als app-impurity rot, danach zurueckgenommen):"
grep -F -- 'app-impurity' <<<"$impurity_out" | sed -n '1,2s/^/full-smoke:   /p'

# ZAHN 2 (ADR-0010 Folgepflicht 7): `driving` und `driven` tragen BEIDE role: adapter —
# ein Import zwischen ihnen ist `lateral-adapter`. Das ist die tragende Regel dieses
# Layouts und KEINE Kante: kein Kanten-Waechter faengt sie, eine Kante hoebe sie nicht auf.
hexdriving="$tmprepo_doc/apps/hexagonal/internal/adapter/driving/cli/cli.go"
cp "$hexdriving" "$hexdriving.orig"
sed -i 's|^\t"app/internal/hexagon/core"$|\t"app/internal/hexagon/core"\n\t_ "app/internal/adapter/driven/memory"|' "$hexdriving"
lateral_rc=0
lateral_out="$( make -C "$tmprepo_doc" a-check-apps-hexagonal 2>&1 )" || lateral_rc=$?
mv "$hexdriving.orig" "$hexdriving"
if [ "$lateral_rc" -eq 0 ]; then
	echo "full-smoke: FEHLER — driving -> driven laesst das Arch-Gate GRUEN (die tragende Regel dieses Layouts ist nur behauptet, ADR-0010 Folgepflicht 7)." >&2
	printf '%s\n' "$lateral_out" >&2
	exit 1
fi
if ! grep -qF -- 'lateral-adapter' <<<"$lateral_out"; then
	echo "full-smoke: FEHLER — Arch-Gate rot, aber NICHT als lateral-adapter (tragen beide Adapter-Schichten noch role: adapter? ADR-0010). Ausgabe:" >&2
	printf '%s\n' "$lateral_out" >&2
	einordnen "make a-check-apps-hexagonal (Zahn 2, lateral-adapter)" "$lateral_out"
	exit 1
fi
echo "full-smoke: hexagonal-Zahn 2 belegt (driving -> driven faerbt a-check als lateral-adapter rot, danach zurueckgenommen):"
grep -F -- 'lateral-adapter' <<<"$lateral_out" | sed -n '1,2s/^/full-smoke:   /p'

# slice-038 (ADR-0007 Idempotenz-Klassifikation): ein ZWEITER Init-Lauf ist IDEMPOTENT
# (Exit 0 statt Kollisions-Refuse). Konvergente Dateien (tool-Infra) werden kanonisch neu
# geschrieben (heilen Drift); skip-if-present-Dateien (Adopter-Boden) bleiben unberuehrt.
echo "full-smoke: Idempotenz — README + Rollen-Typ driften (skip-if-present) + Makefile + Feldliste driften (konvergent), dann 2. Init-Lauf ..."
printf '\n# adopter-gewachsen\n' >> "$tmprepo/README.md"   # skip-if-present: MUSS bleiben
readme_before="$(cat "$tmprepo/README.md")"
# slice-097 (ADR-0022 Festlegung 4, ADR-0007 Festlegung 3): ein Rollen-Typ ist ein Text,
# den der Adopter an sein Repo anpasst — dieselbe Klasse wie die Commands. Ein Re-Lauf,
# der ihn zurueckschriebe, naehme dem Adopter genau die Anpassung, fuer die die Klasse
# gewaehlt ist. Der eingefuegte Satz steht am Ort einer echten Adaption (unter dem
# ANPASSEN-Marker), nicht in einer Nebendatei.
printf '\nDeine Rolle liest zusaetzlich das Betriebshandbuch.\n' >> "$tmprepo/.claude/agents/planner.md"
agent_before="$(cat "$tmprepo/.claude/agents/planner.md")"
printf '\n# drift\n' >> "$tmprepo/Makefile"                # konvergent: MUSS geheilt werden
# Die Feldliste ist konvergent wie das Makefile, und das Dokument sagt es selbst („Ein
# erneuter Lauf des Werkzeugs schreibt diese Datei kanonisch neu."). Hier steht der
# Beleg dafuer, dass der Satz im emittierten Text zutrifft.
printf '\n<!-- von Hand geaendert -->\n' >> "$tmprepo/$FELDLISTE_REL"  # konvergent: MUSS geheilt werden
idem_rc=0
( cd "$tmprepo" && "$tmpbin/ai-harness-init" --lang go --name full-smoke ) || idem_rc=$?
if [ "$idem_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — 2. Init-Lauf ist NICHT Exit 0 (nicht idempotent, slice-038). rc=$idem_rc" >&2
	exit 1
fi
if [ "$(cat "$tmprepo/README.md")" != "$readme_before" ]; then
	echo "full-smoke: FEHLER — 2. Lauf clobberte README.md (skip-if-present verletzt, slice-038)." >&2
	exit 1
fi
if [ "$(cat "$tmprepo/.claude/agents/planner.md")" != "$agent_before" ]; then
	echo "full-smoke: FEHLER — 2. Lauf clobberte .claude/agents/planner.md (skip-if-present verletzt, slice-097)." >&2
	exit 1
fi
if grep -q '# drift' "$tmprepo/Makefile"; then
	echo "full-smoke: FEHLER — 2. Lauf heilte die Makefile-Drift NICHT (konvergent verletzt, slice-038)." >&2
	exit 1
fi
if grep -qF -- '<!-- von Hand geaendert -->' "$tmprepo/$FELDLISTE_REL"; then
	echo "full-smoke: FEHLER — 2. Lauf heilte die Drift in $FELDLISTE_REL NICHT: das Dokument sagt zu, dass ein erneuter Lauf es kanonisch neu schreibt, und dieser Lauf tat es nicht (konvergent verletzt)." >&2
	exit 1
fi

# slice-038 KEIN PRUNE: ein sprachloser 2. Init-Lauf am Mono-Repo-Ziel (tmprepo_doc, das per
# add-lang apps/api + apps/web + blocked/go traegt) darf diese Fragmente NICHT pruen — der
# Init emittiert sie nicht, aber loescht sie auch nicht (die H2-Clobber-Falle eine Ebene tiefer).
echo "full-smoke: kein Prune — sprachloser 2. Init-Lauf am Mono-Repo, add-lang-Fragmente muessen ueberleben ..."
prune_rc=0
( cd "$tmprepo_doc" && "$tmpbin/ai-harness-init" --name full-smoke-doc ) || prune_rc=$?
if [ "$prune_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — sprachloser 2. Init-Lauf ist NICHT Exit 0 (nicht idempotent, slice-038). rc=$prune_rc" >&2
	exit 1
fi
for frag in harness/mk/apps-api.mk harness/mk/apps-web.mk tools/harness/blocked/go apps/api/go.mod \
            harness/mk/apps-engine.mk tools/harness/blocked/cpp apps/engine/CMakeLists.txt; do
	if [ ! -e "$tmprepo_doc/$frag" ]; then
		echo "full-smoke: FEHLER — sprachloser Re-Lauf prunte $frag (kein-Prune verletzt, slice-038)." >&2
		exit 1
	fi
done

echo "full-smoke: OK — frisch gebootstrapptes Repo faehrt make -j gates out-of-the-box gruen (lint/build/test + docs-check + baseline-verify via Fragment-Assembly, record-gates zuletzt), Exit 0 (LH-FA-01/LH-QA-01)."
echo "full-smoke: OK — sprachloser Init (ohne --lang) faehrt make -j gates doc-only gruen (docs-check + baseline-verify, KEIN Code-Gate, kein Skelett) — --lang optional (slice-035/LH-FA-01)."
echo "full-smoke: OK — Gate-Nachweis-Kreis geschlossen: record-gates stempelt, Hash stimmt, .harness/.gitignore greift (slice-031)."
echo "full-smoke: OK — emittierter Command-Guard greift: 'go build' geblockt, 'make test' durchgelassen (bash+awk, slice-032/LH-QA-03)."
echo "full-smoke: OK — Guard-Boden GEBACKEN + blocked/*-Union: --lang go blockt go+pip, sprachlos nur pip (Boden), fail-safe nach geleertem blocked/ (slice-036/ADR-0007 NEU-H1)."
echo "full-smoke: OK — add-lang WIEDERHOLBAR (Mono-Repo): apps/api + apps/web koexistieren, make -j gates faehrt beide modul-scoped Go-Gates, Guard blockt go danach (slice-037/LH-FA-04)."
echo "full-smoke: OK — ZWEITE SPRACHE (slice-039): add-lang cpp apps/engine koexistiert mit den Go-Modulen, make -j gates faehrt die REALEN C++-Gates (cmake/ctest/clang-tidy in Docker), Guard blockt cmake danach (blocked/cpp)."
echo "full-smoke: OK — ARCH-ACHSE (slice-045b/ADR-0009): add-lang go apps/hex --arch hexslice dropt das hexSlice-Layout, make -j gates UEBERSETZT+LINTET den Schichten-Code real (apps-hex build/lint); cpp+hexslice ist fail-fast Exit 2 (sprach×arch-Support, INFO-1)."
echo "full-smoke: OK — ARCH-GATE KONDITIONAL (slice-046/LH-FA-07): --arch hexslice dropt .a-check.yml + a-check.mk + arch-Fragment und make gates FAEHRT a-check real (Modul-scoped apps/hex und am Root); flache Module bekommen keines (LH-QA-01); ein verbotener Domain->Adapter-Import faerbt das Gate rot (Zaehne belegt)."
echo "full-smoke: OK — ARCH-GATE ROBUST (slice-046, Review F-1/F-2): ZWEI hexSlice-Module koexistieren (kein doppelter include, kein 'overriding recipe', beide Gates laufen), und mit gesetztem A_CHECK_IMAGE (Adopter-Override) bleibt das Gate verdrahtet und gruen."
echo "full-smoke: OK — DRITTES LAYOUT (slice-058/ADR-0010): add-lang go apps/hexagonal --arch hexagonal dropt core/port/adapter{driven,driving} in den Pfaden der Familien-Konvention (nicht das --print-config-Geruest), make -j gates uebersetzt+lintet sie real und faehrt ihr a-check mit; cpp+hexagonal ist fail-fast Exit 2. ZAEHNE mit Regel-NAMEN: core->driven = app-impurity, driving->driven = lateral-adapter."
echo "full-smoke: OK — IDEMPOTENT (slice-038): 2. Init-Lauf Exit 0, README (skip-if-present) unberuehrt, Makefile-Drift (konvergent) geheilt; sprachloser Re-Lauf prunt kein add-lang-Fragment (kein Prune)."
echo "full-smoke: OK — ROLLEN-TYPEN (slice-097/LH-FA-10): 6 kanonische Typen unter .claude/agents/ in BEIDEN Bootstrap-Varianten, je mit ihrem Namen im Kopf; das make gates des Ziels laeuft ueber ihnen gruen; der 2. Init-Lauf laesst einen adopter-geaenderten Typ unberuehrt (skip-if-present)."
echo "full-smoke: OK — FELDLISTE (slice-098/LH-FA-10): $FELDLISTE_REL liegt in BEIDEN Bootstrap-Varianten im geprueften Doku-Bereich, fuehrt die drei stehenden Grenz-Saetze und deckt jeden Feldnamen der real geschriebenen Span-Zeile; ein toter Verweis darin faerbt das docs-check des Ziels rot (Ortswahl belegt); ein 2. Init-Lauf heilt eine von Hand geaenderte Fassung (konvergent, die einzige Zusage des Dokuments ueber sich selbst)."
echo "full-smoke: OK — ARCHIVIERUNG IM ZIEL (ADR-0033 Festlegung 4 und 5): make archive-welle ist kein Gate, erreicht aber im gebootstrappten Repo den abgelegten Traeger — die zwei Sperren [untergrenze] und [haenger] halten den Aufruf auf, ueber demselben Bestand ohne sie laeuft die Operation real (Archiv + Stubs aus der vendored Vorlage), und ohne Traeger meldet das Kommando die Abwesenheit mit Exit 0."

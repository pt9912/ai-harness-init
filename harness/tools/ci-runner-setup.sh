#!/usr/bin/env bash
# ci-runner-setup.sh — Runner-Setup der CI-Jobs: die Pflicht-Werkzeuge des Inventars
# an deren Soll stellen (harness/tools/environment-inventory.txt, Spalte 4).
#
# WARUM DIESES SKRIPT STATT ZWEITER DEFINITION IM WORKFLOW. Die CI-Jobs (ci.yml,
# mutate.yml, mutate-branch.yml) rufen nur make-Ziele (MR-014 Setzung 1), und der
# docker-lose Pflicht-Weg (ADR-0109) adressiert das Werkzeug über den PATH des
# Runners — `make environment-check` (erster Check der gates-Kette) belegt ihn.
# Ohne Setup färbt jeder frische Runner am environment-check rot: `go` und
# `golangci-lint` tragen die Prüfform exakt (Soll abgeleitet von GO_VERSION bzw.
# GOLANGCI_LINT_VERSION), `bats`/`shellcheck`/`actionlint` die Prüfform Anwesenheit.
#
# EINE QUELLE. Kein Soll-Wert steht in diesem Skript literal: der Soll je Werkzeug
# ist die Spalte 4 seiner Inventar-Zeile; der Stellen-Abgleich der Doku-Gate-
# Konfiguration (.d-check.yml, pinsync) hält die abgeleitete Inventar-Zeile
# byte-genau gegen die Pin-Stellen. Weicht ein Pin ab, färbt pinsync das Doku-Gate
# rot, bevor dieser Setup still ein altes Soll trägt; passt das Werkzeug am Runner
# nicht zum Inventar, bricht der Lauf an environment-check (Umgebungs-Befund).
#
# WAS ES TUT. Ein exakt-Werkzeug (go, golangci-lint), dessen PATH-Fassung nicht das
# Soll trägt, wird nach .harness-ci/bin installiert; Anwesenheits-Werkzeuge, die am
# PATH fehlen, tragen ihre Besorgung je Werkzeug: bats/shellcheck über apt
# (Runner-Sudo), actionlint über brew — das Ubuntu-Repo trägt das Paket nicht, der
# homebrew-core schon, und die gepinnten GitHub-Runner tragen Linuxbrew
# voreinstalliert am PATH.
# Der d-check-Carrier ist hier nicht: der Transport trägt `make dcheck-fetch`
# (dcheck-fetch.sh — OCI-Digest-Kette, abgelegter Carrier-Pfad der Inventar-Zeile).
# Idempotent: ein Lauf meldet je Werkzeug Soll · Ist · Entscheidung.
#
# GRENZE. Die Install-Zweige brauchen Netz und Runner-Sudo; der reale Runner-Lauf
# trägt sie (DoD welle-ohne-docker, slice-ci-runner-ohne-docker). Der PLAN-Modus
# (CI_RUNNER_SETUP_PLAN=1) ist der hermetische Vorlauf: er stellt an jedem Werkzeug
# Soll · Ist fest und ruft KEINEN Install auf — kein Netz, kein Sudo, Exit 0 auch mit
# fehlender Installation (er stellt fest, er erlegt nicht an). Der Job-Step hängt das
# PREFIX an $GITHUB_PATH, weil der PATH-Umzug zwischen zwei Steps nicht durch eine
# Shell-Variable reist.
#
# GRENZE brew. Der brew-Zug trägt die gepinnten GitHub-Runner (Linuxbrew
# voreinstalliert); ein self-hosted Runner ohne brew bricht an der Aufform (Exit 2,
# fail-closed — die Anwesenheit von actionlint ist Vorab-Form seiner Gates). Die
# actionlint-Version trägt der homebrew-core-Stand der Besorgung; eine Abweichung
# vom gepinnten Image-Digest (ACTIONLINT_IMAGE, opt-in Weg) ist Umgebungs-Befund,
# `make environment-check` belegt die Anwesenheit.

set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
PLAN_MODE=""
if [ "${CI_RUNNER_SETUP_PLAN:-}" = "1" ]; then PLAN_MODE=1; fi
INVENTAR="$REPO/harness/tools/environment-inventory.txt"
PREFIX="$REPO/.harness-ci/bin"

[ -r "$INVENTAR" ] || { echo "ci-runner-setup: Inventar unlesbar: $INVENTAR" >&2; exit 2; }
mkdir -p "$PREFIX"

# soll <werkzeug> — Spalte 4 der Inventar-Zeile ohne Soll-Herkunfts-Praefix
# (abgeleitet:|manifest:); fehlt die Zeile, ist die Inventar-Aufform das rot.
soll() {
	local wert
	wert="$(awk -F'|' -v w="$1" '$1==w { print $4; exit }' "$INVENTAR")"
	wert="${wert#abgeleitet:}"
	wert="${wert#manifest:}"
	case "$wert" in
		'' | probe:* | anwesend)
			echo "ci-runner-setup: Inventar-Zeile für '$1' trägt kein Versions-Soll (Ist: '$wert')" >&2
			exit 2
			;;
		*)
			printf '%s\n' "$wert"
			;;
	esac
}

# version_ist <werkzeug> — dieselbe Probe wie environment-check im exakt-Zweig
# ($(werkzeug) version | erste Zahlen-Fassung): eine zweite Probe-Form wäre eine
# zweite Soll-Auslegung desselben Umgebungs-Befundes. Leer = fehlt oder unlesbar.
version_ist() {
	"$1" version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)*' | head -n 1 || true
}

meldung() {
	printf 'ci-runner-setup: %s · Soll %s · Ist %s — %s\n' "$1" "$2" "$3" "$4"
}

go_soll="$(soll go)"
golangci_soll="$(soll golangci-lint)"

# go: das Soll ist exakt — erst der PATH (Runner-Vorbestand), dann der PREFIX
# (Install eines früheren Laufs), sonst der Install nach PREFIX.
go_ist="$(version_ist go)"
if [ "$go_ist" = "$go_soll" ]; then
	meldung go "$go_soll" "$go_ist" "am PATH — OK"
else
	if [ -x "$PREFIX/go" ] \
		&& [ "$("$PREFIX/go" version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)*' | head -n 1)" = "$go_soll" ]; then
		meldung go "$go_soll" "$go_soll" "im PREFIX — OK"
	elif [ -n "$PLAN_MODE" ]; then
		meldung go "$go_soll" "${go_ist:-fehlt}" "Install ausgesetzt (PLAN)"
	else
		case "$(uname -m)" in
			x86_64) go_arch=amd64 ;;
			aarch64) go_arch=arm64 ;;
			*) echo "ci-runner-setup: uname '$(uname -m)' trägt keine go-Archiv-Form" >&2; exit 2 ;;
		esac
		# Volle Toolchain-Ablage (GOROOT-vollständig) unter .harness-ci/go-<Soll>,
		# das Binary als Symlink an $PREFIX/go — gleiche Zielform wie der
		# golangci-lint-Zweig ($PREFIX/golangci-lint): $PREFIX ist der PATH-Zusatz
		# des Job-Steps, ein Binary unter $PREFIX/bin wäre nicht am PATH. go liest
		# GOROOT über den aufgelösten Binary-Pfad (/proc/self/exe löst den Symlink
		# auf das Archiv-Baum-Layout); die GOROOT-Auflösung trägt der reale
		# Runner-Lauf (LP2), die Stub-Layout-Probe die Ablage-/Prüfform.
		# .harness/state/ ist gitignored — ein frischer CI-Klon trägt es nicht
		# (der lokale Host schon); mktemp -p bricht daran. Install-Zweig allein:
		# der PLAN-Modus verzweigt vorher ab und erreicht kein mktemp.
		mkdir -p "$REPO/.harness/state"
		tmp="$(mktemp -d -p "$REPO/.harness/state")"
		zug="$REPO/.harness-ci/go-$go_soll"
		curl -fsSL "https://go.dev/dl/go${go_soll}.linux-${go_arch}.tar.gz" -o "$tmp/go.tgz"
		tar -xzf "$tmp/go.tgz" -C "$tmp"
		rm -rf "$zug"
		mv "$tmp/go" "$zug"
		ln -sf "$zug/bin/go" "$PREFIX/go"
		rm -rf "$tmp"
		meldung go "$go_soll" "${go_ist:-fehlt}" "installiert nach .harness-ci/bin"
	fi
fi

# golangci-lint: exakt — die Release-Form trägt das v-Praefix, das Inventar-Soll
# die bloße Nummern-Form der Pin-Stelle GOLANGCI_LINT_VERSION; der Install über
# die offizielle install.sh nach PREFIX.
golangci_ist="$(version_ist golangci-lint)"
if [ "$golangci_ist" = "$golangci_soll" ]; then
	meldung golangci-lint "v$golangci_soll" "$golangci_ist" "am PATH — OK"
else
	if [ -x "$PREFIX/golangci-lint" ]; then
		prefix_ist="$("$PREFIX/golangci-lint" version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)*' | head -n 1 || true)"
	else
		prefix_ist=""
	fi
	if [ "$prefix_ist" = "$golangci_soll" ]; then
		meldung golangci-lint "v$golangci_soll" "$prefix_ist" "im PREFIX — OK"
	elif [ -n "$PLAN_MODE" ]; then
		meldung golangci-lint "v$golangci_soll" "${golangci_ist:-fehlt}" "Install ausgesetzt (PLAN)"
	else
		curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh \
			| sh -s -- -b "$PREFIX" "v$golangci_soll"
		meldung golangci-lint "v$golangci_soll" "${golangci_ist:-fehlt}" "installiert nach .harness-ci/bin"
	fi
fi

# Anwesenheit: bats, shellcheck — fehlt eins am PATH, kommt es über apt
# (Runner-Sudo). Die Version trägt keine Pin-Stelle (Prüfform Anwesenheit,
# Inventar-Zeile); `make environment-check` belegt die Anwesenheit.
fehlen=()
for werkzeug in bats shellcheck; do
	if command -v "$werkzeug" >/dev/null 2>&1; then
		meldung "$werkzeug" "anwesend" "anwesend" "am PATH — OK"
	elif [ -n "$PLAN_MODE" ]; then
		meldung "$werkzeug" "anwesend" "fehlt am PATH" "Install ausgesetzt (PLAN)"
	else
		fehlen+=("$werkzeug")
	fi
done
if [ "${#fehlen[@]}" -gt 0 ]; then
	sudo_aufruf=()
	if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
		sudo_aufruf=(sudo -n)
	fi
	"${sudo_aufruf[@]}" apt-get update -qq
	"${sudo_aufruf[@]}" apt-get install -y -qq "${fehlen[@]}"
	for werkzeug in "${fehlen[@]}"; do
		meldung "$werkzeug" "anwesend" "fehlte" "über apt installiert"
	done
fi

# actionlint: brew-Zug statt apt — das Ubuntu-Repo trägt das Paket nicht (apt bricht
# an der Zeile), der homebrew-core schon; die Form ist die Host-erprobte Zusage aus
# .viper.sh (brew install ... actionlint, ohne Flag-Form apt-parallel). Der brew-Pfad
# kommt am Runner am PATH (Linuxbrew voreinstalliert); trägt der PATH nicht, tritt
# der Pflicht-Lager-Pfad ein. Der brew-bin-Verzeichniszug ist am Runner-PATH
# voreingestellt — $GITHUB_PATH braucht keinen Eintrag. Version je homebrew-core-Stand
# (Prüfform bleibt Anwesenheit, siehe Grenze brew oben); brew fehlt → Exit 2,
# fail-closed.
brewform="$(command -v brew || true)"
if [ -z "$brewform" ] && [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
	brewform=/home/linuxbrew/.linuxbrew/bin/brew
fi
if command -v actionlint >/dev/null 2>&1; then
	meldung actionlint anwesend anwesend "am PATH — OK"
elif [ -n "$PLAN_MODE" ]; then
	meldung actionlint anwesend "fehlt am PATH" "Install ausgesetzt (PLAN)"
elif [ -n "$brewform" ]; then
	"$brewform" install actionlint
	meldung actionlint anwesend "fehlt am PATH" "über brew installiert"
else
	echo "ci-runner-setup: actionlint fehlt am PATH und brew trägt nicht am Runner" >&2
	exit 2
fi

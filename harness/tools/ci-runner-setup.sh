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
# Soll trägt, wird nach $HARNESS_CI_DIR/bin installiert — die Install-Ablage liegt
# AUSSERHALB des Repo-Baums (RUNNER_TEMP-Form am Runner, /tmp-Fallback am Host-Lauf);
# im Baum lag sie unter .harness-ci/ und der Doku-Scan las die Go-Doku im
# Toolchain-Baum mit (Go verteilt doc/*.md) · seit slice-ci-runner-ohne-docker.
# Anwesenheits-Werkzeuge, die am
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
# voreinstalliert, aber NICHT im PATH — der brew-bin-Verzeichniszug reist
# deshalb an $GITHUB_PATH, sobald brew anwesend ist; der Runner-Form des
# Environment-Checks belegt das Folgerschritt-PATH). Ein self-hosted Runner
# ohne brew bricht an der Aufform (Exit 2, fail-closed — die Anwesenheit von
# actionlint ist Vorab-Form seiner Gates). Die actionlint-Version trägt der
# homebrew-core-Stand der Besorgung; eine Abweichung vom gepinnten
# Image-Digest (ACTIONLINT_IMAGE, opt-in Weg) ist Umgebungs-Befund,
# `make environment-check` belegt die Anwesenheit.

set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
BREW_BIN="/home/linuxbrew/.linuxbrew/bin"
PLAN_MODE=""
if [ "${CI_RUNNER_SETUP_PLAN:-}" = "1" ]; then PLAN_MODE=1; fi
INVENTAR="$REPO/harness/tools/environment-inventory.txt"
HARNESS_CI_DIR="${RUNNER_TEMP:-/tmp}/ai-harness-ci"
PREFIX="$HARNESS_CI_DIR/bin"

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
		# Volle Toolchain-Ablage (GOROOT-vollständig) unter $HARNESS_CI_DIR/go-<Soll>,
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
		zug="$HARNESS_CI_DIR/go-$go_soll"
		curl -fsSL "https://go.dev/dl/go${go_soll}.linux-${go_arch}.tar.gz" -o "$tmp/go.tgz"
		tar -xzf "$tmp/go.tgz" -C "$tmp"
		rm -rf "$zug"
		mv "$tmp/go" "$zug"
		ln -sf "$zug/bin/go" "$PREFIX/go"
		rm -rf "$tmp"
		meldung go "$go_soll" "${go_ist:-fehlt}" "installiert nach $PREFIX"
	fi
fi

# golangci-lint: exakt — die Release-Form trägt das v-Praefix (Meldung), das
# Inventar-Soll die bloße Nummern-Form der Pin-Stelle GOLANGCI_LINT_VERSION;
# der Install ist die go install-Form der Host-Erprobung (.viper.sh). GOBIN
# setzt die Ablage auf denselben PREFIX — eine Zielform, keine zweite Ablage.
# install.sh aus raw.githubusercontent trägt der Install nicht mehr: seine
# Tag-Auflösung läuft über api.github.com und fiel dort dauerhaft als 504 aus
# · seit slice-ci-runner-ohne-docker. proxy.golang.org trägt die CDN-Form der
# Abholung, sum.golang.org die Modul-Verifikation am Lauf — die Checksum-Form
# kommt mit dem Weg, kein Traeger-Musterzug hier. go selbst trägt der
# go-Zweig davor (am PATH oder im PREFIX); die Übergabe des PREFIX an den
# PATH des Install-Aufrufs verdrahtet die PREFIX-Ablage des go-Zweigs nach.
# Grenze: ein im Runner-Umfeld gesetztes GOFLAGS trägt die Umgebungs-Form —
# ihr Ort ist der reale Runner-Lauf; das Toolchain-Nachziehen (GOTOOLCHAIN)
# bleibt unverändert.
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
		golangci_go="$(command -v go || true)"
		[ -n "$golangci_go" ] || golangci_go="$PREFIX/go"
		[ -x "$golangci_go" ] || {
			echo "ci-runner-setup: go trägt nicht für die golangci-Install (weder PATH noch $PREFIX/go)" >&2
			exit 2
		}
		GOBIN="$PREFIX" PATH="$PREFIX:$PATH" "$golangci_go" install "github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v$golangci_soll"
		meldung golangci-lint "v$golangci_soll" "${golangci_ist:-fehlt}" "installiert nach $PREFIX"
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
# .viper.sh (brew install ... actionlint, ohne Flag-Form apt-parallel). Trägt der PATH
# keinen brew, tritt der Pflicht-Lager-Pfad ($BREW_BIN) ein — und sofern der Lauf ein
# Runner-Job ist ($GITHUB_PATH gesetzt), reist das brew-bin-Verzeichnis an
# $GITHUB_PATH: der Runner trägt Linuxbrew voreinstalliert, aber NICHT im PATH, ohne
# den Eintrag sieht der Folgerschritt (environment-check) die installierte Binary
# nicht. Der Host-Lauf ohne $GITHUB_PATH trägt seinen PATH selbst (.viper.sh-Form) —
# Grenze hier. Version je homebrew-core-Stand (Prüfform bleibt Anwesenheit, siehe
# Grenze brew oben); brew fehlt → Exit 2, fail-closed.
brewform="$(command -v brew || true)"
if [ -z "$brewform" ] && [ -x "$BREW_BIN/brew" ]; then
	brewform="$BREW_BIN/brew"
fi
if [ -n "$brewform" ] && [ -n "${GITHUB_PATH:-}" ]; then
	printf '%s\n' "$(dirname "$brewform")" >> "$GITHUB_PATH"
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

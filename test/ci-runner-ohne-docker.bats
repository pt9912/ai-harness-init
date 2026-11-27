#!/usr/bin/env bats
# ci-runner-ohne-docker.bats — Wächter an der Workflow-Form der CI-Jobs ohne
# Docker-Daemon (slice-ci-runner-ohne-docker; ADR-0109, MR-014).
#
# HERMETISCH: kein Docker, kein Netz. Gelesen wird der Workflow-Text der realen
# Dateien (kein Fixture-Doppel); die Job-Blöcke löst awk über die 2-Spalten-Einrückung
# der Jobköpfe auf. Die CI-Form-Doku ist im
# slice-doku-nachzug-ohne-docker (Sensors-Tabellen); dieser Wächter trägt die Form.
#
# ROT-GEGENPROBEN (AGENTS.md §3.6), je Form der benannte Grund — je Fall wurde der
# Griff an der REALEN Quelle gefahren und der rot gesehene Lauf über den Bestand
# gefahren (Protokoll im Bericht des Slices):
#   - Fällt die Vorlauf-Kette in ci.yml/mutate.yml/mutate-branch.yml (der
#     ci-runner-setup-Step entfernt der hinter das make-Gang geschoben), färbt der
#     Fall "vorlaufskette" rot.
#   - Fällt die Carrier-Preposition (dcheck-fetch), färbt der Fall "carrier" rot.
#   - Fällt die Daemon-Freiheit (ein docker run/build-Step in einem der drei
#     Workflows), färbt der Fall "daemonfrei" rot.
#   - Fällt "eine Quelle" (ein Soll-Wert literal im Workflow oder Skript), färbt
#     der Fall "einequelle" rot.
#   - Fällt die Grenze des Tag-Workflows (release.yml verliert seinen
#     release-artifacts-Aufruf oder gewinnt ci-runner-setup), färbt der Fall
#     "releasegrenze" rot.
#
# GRENZE: die Prüfung liest die Form (Zeilenpositionen der make-Aufrufe in den
# Job-Körpern), nicht die YAML-Semantik — ein Job-Kopf, der die 2-Spalten-Einrückung
# verlässt, verliert hier seine Zuordnung; ein verlorenes make-Gang färbt die
# "vorlaufskette"-Fälle rot, der bloße Einrückungs-Wechsel selbst nicht. Das Skript
# ci-runner-setup.sh prüft der Fall "einequelle-skript" textuell, nicht seine
# Install-Zweige (Netz/Sudo — Grenze im Skriptkopf).

setup() {
	bats_require_minimum_version 1.5.0
	REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
	WF="$REPO/.github/workflows"
}

# _job_reihenfolge <datei> <muster> [<job>] — für jeden (bzw. den benannten) Job,
# der den make-Aufruf des Musters trägt: 1) er trägt `make ci-runner-setup` VOR dem
# Aufruf, 2) er trägt `make dcheck-fetch` VOR dem Aufruf. Der Muster-Match trägt die
# Wort-Grenze und die make-Flags (mutate-branch SCHRITT=shard ist
# `make --no-print-directory mutate-branch …`); Kommentarzeilen sind abgestreift —
# sie nennen make-Aufrufe, ohne sie zu fahren.
_job_reihenfolge() {
	local datei="$1" muster="$2" filter="${3:-}" fehler=""
	fehler="$(awk -v re="make[ \t](-{1,2}[^ \t]+[ \t]+)*$muster([^A-Za-z0-9_-]|$)" -v filter="$filter" '
		{
			sub(/#.*/, "")
			if ($0 ~ /^[a-zA-Z_][a-zA-Z0-9_-]*$/) next
			if ($0 ~ /^[ \t][ \t][a-z][a-zA-Z0-9_-]*:[ \t]*$/) { job = $1; sub(/:.*/, "", job) }
			if ($0 ~ /make[ \t]ci-runner-setup/ && !(job in setup)) setup[job] = NR
			if ($0 ~ /make[ \t]dcheck-fetch/ && !(job in carrier)) carrier[job] = NR
			if ($0 ~ re && !(job in gang)) gang[job] = NR
		}
		END {
			fehl = 0
			for (j in gang) {
				if (filter != "" && j != filter) continue
				if (!(j in setup)) { print "Job " j ": kein ci-runner-setup"; fehl = 1 }
				else if (setup[j] > gang[j]) { print "Job " j ": ci-runner-setup (Zeile " setup[j] ") nach dem Gang (Zeile " gang[j] ")"; fehl = 1 }
				if (!(j in carrier)) { print "Job " j ": kein dcheck-fetch"; fehl = 1 }
				else if (carrier[j] > gang[j]) { print "Job " j ": dcheck-fetch (Zeile " carrier[j] ") nach dem Gang (Zeile " gang[j] ")"; fehl = 1 }
			}
			gelaufen = 0
			for (j in gang) {
				if (filter != "" && j != filter) continue
				gelaufen++
			}
			if (gelaufen < 1) { print "kein Job trägt den Gang — das Muster verliert sich"; fehl = 1 }
			exit fehl
		}' "$datei")"
	[ -z "$fehler" ]
}

# _kein_docker <datei> — der kommentar-bereinigte Workflowtext trägt keinen
# docker-Verwaltungsauf (run/build/create/commit/pull/push) in einem run-Körper.
_kein_docker() {
	local datei="$1" treffer=""
	treffer="$(sed 's/#.*//' "$datei" | grep -nE '[ \t]docker (run|build|create|commit|pull|push)\b' || true)"
	[ -z "$treffer" ] || { echo "$treffer" >&2; return 1; }
}

@test "ci.yml: gates-, smoke- und full-smoke-Jobs tragen die Vorlauf-Kette vor dem Gang" {
	_job_reihenfolge "$WF/ci.yml" gates gates
	_job_reihenfolge "$WF/ci.yml" smoke smoke
	_job_reihenfolge "$WF/ci.yml" full-smoke "full-smoke"
}

@test "mutate.yml: der Job trägt die Vorlauf-Kette vor dem Lauf" {
	_job_reihenfolge "$WF/mutate.yml" mutate mutate
}

@test "mutate-branch.yml: der shard-Job trägt die Vorlauf-Kette vor dem Fall-Lauf" {
	_job_reihenfolge "$WF/mutate-branch.yml" mutate-branch shard
}

@test "die drei Workflows tragen keinen Docker-Aufruf in einem run-Körper" {
	_kein_docker "$WF/ci.yml"
	_kein_docker "$WF/mutate.yml"
	_kein_docker "$WF/mutate-branch.yml"
}

@test "mutate-branch.yml: der shard-Step trägt den Carrier-Pfad aus der Umgebung" {
	grep -q 'DCHECK_CARRIER' "$WF/mutate-branch.yml"
	grep -q '/.harness/state/bin/d-check' "$WF/mutate-branch.yml"
}

@test "die Soll-Werte von go und golangci-lint stehen nicht literal in den drei Workflows" {
	for datei in "$WF/ci.yml" "$WF/mutate.yml" "$WF/mutate-branch.yml"; do
		treffer="$(grep -nE '([ \t@=])(v?1\.27\.4|v?2\.15\.0)\b' "$datei" || true)"
		[ -z "$treffer" ] || { echo "$datei: $treffer" >&2; return 1; }
	done
}

@test "das Setup-Skript liest das Inventar und trägt kein Soll literal" {
	grep -q 'environment-inventory.txt' "$REPO/harness/tools/ci-runner-setup.sh" \
		|| { echo "Skript liest das Inventar nicht" >&2; return 1; }
	treffer="$(grep -nE '(v?1\.27\.4|v?2\.15\.0)\b' "$REPO/harness/tools/ci-runner-setup.sh" || true)"
	[ -z "$treffer" ] || { echo "$treffer" >&2; return 1; }
}

@test "der Tag-Workflow bleibt gepinnt-image-getrieben" {
	sed 's/#.*//' "$WF/release.yml" | grep -q 'make release-artifacts' \
		|| { echo "release.yml verliert den release-artifacts-Aufruf" >&2; return 1; }
	treffer="$(sed 's/#.*//' "$WF/release.yml" | grep -n 'ci-runner-setup' || true)"
	[ -z "$treffer" ] || { echo "$treffer" >&2; return 1; }
}

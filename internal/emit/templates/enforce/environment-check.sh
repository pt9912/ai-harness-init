#!/usr/bin/env bash
# environment-check — Tool-/Versions-Check der emittierten Gates. Erster Check
# der Gates-Kante (harness/mk/environment.mk stellt ihn vor alle Checks):
# Rot hier ist ein Umgebungs-Befund, kein Code-Befund — der Gate-Lauf endet an
# ihm, bevor ein Gate gegen fehlendes Werkzeug falsch faerbt.
#
# VERTRAG: Spezifikation SPEC-099 (Pruefformen je Werkzeug, Vergleichs- und
# Exit-Formen). Inventar: tools/harness/environment-inventory.txt (default,
# nebenliegend; --inventar ueberschreibt) — zeilenweise, `|`-getrennt, sechs
# Spalten werkzeug|pruefform|pflichtgrad|soll|kontext|grund; pruefform ist die
# geschlossene Menge ANWESENHEIT | MINDESTVERSION | FAEHIGKEIT | EXAKT
# (geschrieben Faehigkeit, ASCII). Soll-Herkunft als Praefix im Soll-Feld:
# `manifest:` (das Inventar traegt den Wert), `abgeleitet:` (der Wert steht vom
# Pin abgeleitet — die Sprach-Toolchains; die Emissions-Tests in
# internal/emit/environment_test.go halten die abgeleitete Zeile gegen die Pin-
# Stelle im Sprach-Fragment).
#
# WEG: docker-los am Host (ADR-0109). Die d-check-Anwesenheit traegt die
# fetched Ablage .harness/state/bin/d-check (make dcheck-fetch; Beschaffung:
# tools/harness/dcheck-fetch.sh). Fuehrt ein Ziel den gepinnten Image-Weg
# (opt-in), adressiert der Digest die Werkzeuge dort, dieser Check vergleicht
# sie nicht.
#
# HERKUNFT: Engine-Kopie der Lab-Fassung des erzeugenden Werkzeugs
# (harness/tools/environment-check.sh): ab dem bash-Guard unten (Zeile
# `if ((BASH_VERSINFO[0] < 4))` und alles darunter) laeuft sie nach Streichen
# der Kommentarzeilen Zeile fuer Zeile mit ihr gleich — gehalten vom
# Engine-Identitaets-Waechter in internal/emit/environment_test.go; die
# Werkzeug-Kommentare in der Mitte nennen die Ziel-Pfade. Die Inventar-Zeilen
# sind Eigenfassung des Ziels — der Basissatz steht hier, die Sprach-Zeilen
# haengt der Bootstrap an (dedupliert je Werkzeugname, Soll ersetzt).
#
# BREAK-BELEG: die Pruefformen und Abbruch-Formen tragen die Lab-Fassung als
# rot gesehener Beleg (PROTOKOLL dort, harness/sensors/environment-check.md);
# dieses Skript fuehrt dieselben Formen, seine emissionsseitigen Waechter
# pruefen Verdrahtung und Inventar, nicht die Formen erneut gegen sich.
#
# AUFFORM (Exit 2, fail-closed): unlesbares oder leeres Inventar, Zeile mit
# anderer Spaltenzahl, unbekannte Pruefform oder unbekannter Pflichtgrad,
# Soll-Feld ohne Quelle, Faehigkeits-Soll mit unbekannter Probe-ID. Der
# bash-Guard unten steht als ERSTER Top-Level-Befehl und nur mit Builtins:
# unterhalb der Inventar-Mindestversion (4.0) endet der Lauf mit einer
# Diagnose statt mit einem Syntaxfehler.
if ((BASH_VERSINFO[0] < 4)); then
    printf '%s\n' "environment-check: bash ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]} liegt unter der Inventar-Mindestversion 4.0 (inventory-Zeile bash) — neueres bash in den PATH stellen" >&2
    exit 2
fi
set -euo pipefail

# Builtin statt dirname (LH-QA-03-Klasse: kein Werkzeug, das nicht im Inventar
# steht): der Default-Inventar-Pfad löst an $0.
case "$0" in
    */*) SKRIPT_DIR="${0%/*}" ;;
    *) SKRIPT_DIR="." ;;
esac
# Repo-Wurzel an $0 abgleitet (nicht cwd): das Skript liegt unter tools/harness/,
# die Ablage-Fassung der d-check-Anwesenheit unten ist repo-bezogen; `make
# environment-check` ist die einzige Verdrahtung.
REPO_ROOT="$(cd "${SKRIPT_DIR}/../.." && pwd)"
INVENTAR="${SKRIPT_DIR}/environment-inventory.txt"
FORM_ONLY=0

usage() {
    printf '%s\n' "usage: environment-check.sh [--inventar <pfad>] [--form-only]" >&2
    exit 2
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --inventar)
            [ "$#" -ge 2 ] || usage
            INVENTAR="$2"
            shift 2
            ;;
        --form-only)
            FORM_ONLY=1
            shift
            ;;
        *)
            usage
            ;;
    esac
done

aufform() {
    printf '%s\n' "environment-check: AUFFORM — $1 (fail-closed)" >&2
    exit 2
}

[ -r "$INVENTAR" ] || aufform "Inventar '$INVENTAR' unlesbar"

# min_unterschritten <ist> <soll> — 0, wenn ist unter soll liegt (nummerisch,
# Punkt-komponentenweise); 1 sonst oder bei Gleichheit.
min_unterschritten() {
    local -a a b
    local i n1 n2 x y
    IFS='.' read -r -a a <<<"$1"
    IFS='.' read -r -a b <<<"$2"
    n1=${#a[@]}
    n2=${#b[@]}
    for ((i = 0; i < n1 && i < n2; i++)); do
        x=${a[i]}
        y=${b[i]}
        if ((10#$x < 10#$y)); then return 0; fi
        if ((10#$x > 10#$y)); then return 1; fi
    done
    [ "$n1" -lt "$n2" ]
}

probe_git_version() {
    local out
    out="$(git --version 2>/dev/null || true)"
    [ "${out#git version}" != "$out" ]
}

probe_make_gnu() {
    local out
    out="$(make --version 2>/dev/null | head -n1 || true)"
    [ "${out#GNU Make}" != "$out" ]
}

probe_sed_join() {
    local out
    out="$(printf 'a\\\nb\n' | sed -e :a -e '/\\$/N; s/\\\n//; ta' 2>/dev/null || true)"
    [ "$out" = "ab" ]
}

probe_mktemp_pdir() {
    local f p
    p="${TMPDIR:-/tmp}"
    f="$(mktemp -p "$p" envchk.XXXXXX 2>/dev/null || true)"
    if [ -n "$f" ] && [ -f "$f" ]; then
        rm -f "$f"
        return 0
    fi
    return 1
}

probe_sha256_abc() {
    local d
    d="$(printf 'ABC' | sha256sum 2>/dev/null | cut -d' ' -f1 || true)"
    [ "$d" = "b5d4045c3f466fa91fe2cc6abe79232a1a57cdf104f7a26e716e0a1e2789df78" ]
}

# Anwesenheit des fetched d-check an der Ablage (make dcheck-fetch legt nach
# .harness/state/bin/): der PATH führt das Binary am Host meist nicht, die
# Anwesenheits-Prüfform sieht darum AUSDRÜCKLICH auch die Ablage — als benannte
# Erweiterung, nicht still (Inventar-Zeile d-check, Grund-Spalte, gleiche Herkunft).
# Zusage: die Probe misst Anwesenheit und Ausführbar-Form — NICHT, dass es die
# gepinnte Fassung ist; die trägt der Fetch mit seiner Digest-Kette (Kopf von
# tools/harness/dcheck-fetch.sh). DCHECK_CARRIER überschreibt (absolute Form).
probe_dcheck_ablage() {
    local p="${DCHECK_CARRIER:-$REPO_ROOT/.harness/state/bin/d-check}"
    [ -x "$p" ]
}

# probe_id_fuer <werkzeug> -> die Probe-ID, die das Skript für das Faehigkeits-
# Werkzeug traegt; leer, wenn keines existiert. Unstimmig mit dem Inventar-
# Soll ist AUFFORM — die zwei Faecher driften nicht still.
probe_id_fuer() {
    case "$1" in
        git) printf '%s' "git-version" ;;
        make) printf '%s' "make-gnu" ;;
        sed) printf '%s' "sed-join" ;;
        mktemp) printf '%s' "mktemp-pdir" ;;
        sha256sum) printf '%s' "sha256-abc" ;;
        *) return 1 ;;
    esac
}

PRUEF_ZAHL=0
PFLICHT_GESAMT=0
BEFUNDE=""
WARNS=""
BEFUND_ZAHL=0
WARN_ZAHL=0

zeilenform_pruefen() {
    # $1 zeilennummer, $2..$6 felder — nur Form, ohne Probe (--form-only und
    # Vollform shared).
    local nr="$1" w="$2" pf="$3" grad="$4" soll="$5"
    case "$grad" in
        pflicht | optional) ;;
        *) aufform "Inventar-Zeile $nr: unbekannter Pflichtgrad '$grad'" ;;
    esac
    case "$pf" in
        Anwesenheit) ;;
        Mindestversion) ;;
        Faehigkeit) ;;
        exakt) ;;
        *) aufform "Inventar-Zeile $nr: unbekannte Pruefform '$pf' (geschlossene Menge: Anwesenheit, Mindestversion, Faehigkeit, exakt)" ;;
    esac
    case "$soll" in
        manifest:anwesend)
            [ "$pf" = "Anwesenheit" ] || aufform "Inventar-Zeile $nr: 'manifest:anwesend' trägt nur zur Pruefform Anwesenheit"
            ;;
        manifest:probe:*)
            [ "$pf" = "Faehigkeit" ] || aufform "Inventar-Zeile $nr: manifest:probe:* trägt nur zur Pruefform Faehigkeit"
            [ "${soll#manifest:probe:}" != "" ] || aufform "Inventar-Zeile $nr: Faehigkeits-Soll ohne Probe-ID"
            ;;
        manifest:* | abgeleitet:*)
            [ "$pf" = "exakt" ] || [ "$pf" = "Mindestversion" ] || aufform "Inventar-Zeile $nr: Wert-Soll trägt nur zur Pruefform exakt oder Mindestversion"
            [ "${soll#*:}" != "" ] || aufform "Inventar-Zeile $nr: Soll ohne Wert"
            ;;
        *)
            aufform "Inventar-Zeile $nr: Soll ohne Quelle (manifest:|abgeleitet:): '$soll'"
            ;;
    esac
    [ "$w" != "" ] || aufform "Inventar-Zeile $nr ohne Werkzeug"
    return 0
}

while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
        '' | \#*) continue ;;
    esac
    PRUEF_ZAHL=$((PRUEF_ZAHL + 1))
    IFS='|' read -r -a f <<<"$line"
    [ "${#f[@]}" -eq 6 ] || aufform "Inventar-Zeile $PRUEF_ZAHL trägt ${#f[@]} statt 6 Spalten: $line"
    w="${f[0]}" pf="${f[1]}" grad="${f[2]}" soll="${f[3]}"
    zeilenform_pruefen "$PRUEF_ZAHL" "$w" "$pf" "$grad" "$soll"
    anzeige="${soll#*:}"
    anzeige="${anzeige#probe:}"
    if [ "$grad" = "pflicht" ]; then
        PFLICHT_GESAMT=$((PFLICHT_GESAMT + 1))
    fi
    if [ "$FORM_ONLY" -eq 1 ]; then
        continue
    fi
    ist=""
    gut=1
    if ! command -v "$w" >/dev/null 2>&1; then
        # d-check: außerhalb des PATH trägt die fetched Ablage (probe_dcheck_ablage,
        # make dcheck-fetch) die Anwesenheit — die benannte Erweiterung der
        # Prüfform-Auflage, nicht still; ohne Ablage bleibt der Befund "fehlt".
        if [ "$w" = "d-check" ] && probe_dcheck_ablage; then
            gut=1
        else
            ist="fehlt"
            gut=0
        fi
    fi
    if [ "$gut" -eq 1 ] && command -v "$w" >/dev/null 2>&1; then
        case "$pf" in
            Anwesenheit)
                gut=1
                ;;
            Mindestversion)
                if [ "$w" = "bash" ]; then
                    # Der Interpreter unter diesem Skript ist der Gegenstand;
                    # `bash --version` aus dem PATH koennte eine andere
                    # Fassung nennen.
                    ist="$(printf '%s.%s' "${BASH_VERSINFO[0]}" "${BASH_VERSINFO[1]}")"
                else
                    ist="$("$w" --version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)*' | head -n1 || true)"
                fi
                if [ -z "$ist" ]; then
                    ist="unlesbar"
                    gut=0
                elif min_unterschritten "$ist" "$anzeige"; then
                    gut=0
                else
                    gut=1
                fi
                ;;
            exakt)
                ist="$("$w" version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)*' | head -n1 || true)"
                if [ -z "$ist" ]; then
                    ist="unlesbar"
                    gut=0
                elif [ "$ist" = "$anzeige" ]; then
                    gut=1
                else
                    gut=0
                fi
                ;;
            Faehigkeit)
                erwartet="$(probe_id_fuer "$w" || true)"
                [ "$erwartet" = "${soll#manifest:probe:}" ] || aufform "Inventar-Zeile $PRUEF_ZAHL: Faehigkeits-Soll '${soll#manifest:probe:}' trägt nicht die Probe-ID des Skripts für '$w'"
                case "$w" in
                    git) probe_git_version && gut=1 || gut=0 ;;
                    make) probe_make_gnu && gut=1 || gut=0 ;;
                    sed) probe_sed_join && gut=1 || gut=0 ;;
                    mktemp) probe_mktemp_pdir && gut=1 || gut=0 ;;
                    sha256sum) probe_sha256_abc && gut=1 || gut=0 ;;
                esac
                if [ "$gut" -eq 0 ]; then
                    ist="probe fehlgeschlagen: ${soll#manifest:probe:}"
                fi
                ;;
        esac
    fi
    if [ "$gut" -eq 1 ]; then
        continue
    fi
    if [ "$grad" = "optional" ]; then
        WARNS="${WARNS}umgebung-warn: $w · Soll: $anzeige · Ist: $ist (optional)
"
        WARN_ZAHL=$((WARN_ZAHL + 1))
    else
        BEFUNDE="${BEFUNDE}umgebung: $w · Soll: $anzeige · Ist: $ist
"
        BEFUND_ZAHL=$((BEFUND_ZAHL + 1))
    fi
done <"$INVENTAR"

if [ "$PRUEF_ZAHL" -eq 0 ]; then
    aufform "Inventar '$INVENTAR' ohne Zeile"
fi

if [ "$FORM_ONLY" -eq 1 ]; then
    printf 'environment-check: Inventar formt — %s Zeilen, %s Pflicht, %s optional\n' "$PRUEF_ZAHL" "$PFLICHT_GESAMT" "$((PRUEF_ZAHL - PFLICHT_GESAMT))"
    exit 0
fi

if [ "$BEFUND_ZAHL" -gt 0 ]; then
    printf 'environment-check: UMFELD-BEFUND — %s von %s Pflicht-Werkzeugen tragen ihr Soll nicht:\n' "$BEFUND_ZAHL" "$PFLICHT_GESAMT"
    [ -z "$WARNS" ] || printf '%s' "$WARNS"
    printf '%s' "$BEFUNDE"
    exit 1
fi

printf 'environment-check: grün — %s/%s Pflicht-Werkzeuge tragen ihr Soll.\n' "$PFLICHT_GESAMT" "$PFLICHT_GESAMT"
if [ "$WARN_ZAHL" -gt 0 ]; then
    printf '%s' "$WARNS"
fi
exit 0

#!/usr/bin/env bash
# full-smoke-varianten — Satzerzeuger der je-Variante-E2E-Stempel-Schluessel
# (ADR-0113 Festlegungen 1 und 2, Plan slice-full-smoke-jevariante-stempel-v1;
# Form harness/tools/gates-keys.sh, ADR-0108-Fassung je Variante statt je Check).
# EINE Definition je Vorlagen-Menge, vier Moden:
#   menge <variante>  — die Dateien der Vorlagen-Menge der Variante, zeilenweise
#   hash <variante>   — der Inhalt-Hash der Tafel-Menge der Variante, 64 Hex
#   alle              — je Variante der Hash, je Zeile `<variante> <hash>` (der
#                       Schreiber-Zug am Treiber liest genau diese Form: full-smoke.sh
#                       schreibt daraus die sieben Stempel-Dateien, ADR-0113 Festlegung 4)
#   pruefe            — der Mengen-Waechter (Festlegung 2): jede nicht-Test-Quelle von
#                       internal/gen liegt in mindestens einer Tafel-Zeile (je-Sprache-Teil
#                       oder GEN_GEMEINSAM) — sonst Liste und Exit 1. Eine Menge, die
#                       eine Quelle still vergisst, verleugnet den Schluessel ihren
#                       Pruefgegenstand; eine deklarierte Zeile, die nichts mehr trifft,
#                       verengt die Menge still — beides faellt hier rot
#                       (fail-closed, MR-017).
# Hermetisch: `--wurzel <dir>` loest die Wurzel ohne git auf (gepinntes bats-Image,
# Fixture); ohne `--wurzel` gilt das git-Toplevel, und ohne git der Lauf ueber
# `find` — dieselbe Walk-Form wie gates-keys.sh und working-tree-hash.sh (getrackt
# + untracked, Zeilen ./-frei, C-sortiert).
#
# DIE TAFEL (Festlegung 2) je Variante aus zwei Teilen. GEMEINSAME MENGE (alle
# sieben): cmd/** und internal/** ohne *_test.go und ohne testdata/** (die
# Traeger-Quelle samt den eingebetteten Emit-Vorlagen, die als Build-Quelle im
# einen Binary reisen), die vendored Baseline .harness/baseline/** (jeder
# Ziel-Bootstrap Faehrt sie nach) und die drei Treiber-Skripte full-smoke.sh,
# full-smoke-skip.sh, handbuch-baum.sh — sie tragen die Messung selbst, ein
# Treiber-Edit kann jedes Varianten-Verdikt drehen, und sie aus den Mengen zu
# nehmen waere eine Senkung nach AGENTS.md §3.5. JE-SPRACHE-TEIL (die
# Profil-Dateien der Tafel je Zeile mit Grund): go und sprachlos lesen
# golang.go (die Sprachlose bootstrapt kein Skelett, Faehrt aber den add-lang-Zug
# — ihr Verdikt haengt am Go-Profil), cpp cpp.go, kotlin kotlin.go+jvm.go,
# java java.go+java_hexslice.go+jvm.go, python python.go+python_hexslice.go,
# csharp csharp.go+csharp_hexslice.go. Nicht groesser: Dateien, die das
# Varianten-Verdikt nicht tragen (Tests, Doku, Planning, Testdata), treten aus;
# nicht kleiner: pruefe haelt die Zuordnung ueber dem Bestand.
#
# Der Satzerzeuger selbst liegt in keiner Menge — er ist der Massstab, nicht
# Pruefgegenstand (Form gates-keys.sh). Die Stempel-Dateien selbst liegen unter
# .harness/state/ und treffen keine Menge-Zeile — ein Key deckt sich nicht selbst
# (Form MENGE_AUSSCHLUESS dort).
set -euo pipefail

# VARIANTEN — die Menge der Stempel-Klasse .harness/state/full-smoke-passed-<variante>.key,
# dieselbe wie die Varianten-Schleife des Handbuch-Baums in full-smoke.sh (ADR-0113
# Festlegung 1). Eine neue E2E-Variante braucht vor ihrem ersten Stempel eine
# Tafel-Zeile (Re-Evaluierungs-Trigger 2; ueber einer ungefahren Menge wird kein
# Key gestempelt).
VARIANTEN=(sprachlos go cpp kotlin java python csharp)

# GEN_GEMEINSAM — die gemeinsamen Gen-Dateien, die keinem je-Teil gehoeren
# (ADR-0113 Festlegung 2: der gemeinsame Renderer gen.go und die Arch-Auswahl
# arch.go tragen jedes Varianten-Verdikt). pruefe haelt die Zuordnung gegen den
# Bestand: eine Datei hier fehlt im Gemeinsam-Teil nie, weil die Aufnahme-Zeile
# ./internal/* sie traegt.
GEN_GEMEINSAM=(
    './internal/gen/gen.go'   # der gemeinsame Renderer aller Profile
    './internal/gen/arch.go'  # die Arch-Auswahl, kein Profilskelett
    './internal/gen/jvm.go'   # der Gemeinsam-Knoten der zwei JVM-Sprachen — je kotlin und je java zugeordnet
)

# variante_bekannt <variante> — eine Variante ohne Tafel-Zeile ist unbekannt
# (fail-closed, MR-017).
variante_bekannt() {
  local v
  for v in "${VARIANTEN[@]}"; do
    [ "$v" = "$1" ] && return 0
  done
  printf 'unbekannte Variante: %s\n' "$1" >&2
  return 1
}

# in_gemeinsam <pfad ./-frei> — der Gemeinsam-Teil der Tafel: Ausschluesse
# (Tests, Testdata, je-Teil-Profil-Dateien) vor der Aufnahme, sonst fail-closed
# rot. Die Patterns sind Inline-Literale; `*` durchlaeuft Trenner (dieselbe
# Lesung wie glob_zu_regex in gates-keys.sh).
in_gemeinsam() {
  local f="./$1"
  case "$f" in
    # Tests und Testdata tragen das Varianten-Verdikt nicht (Festlegung 2: nicht groesser)
    ./internal/*_test.go | ./cmd/*_test.go | ./internal/*/testdata/* | ./cmd/*/testdata/*) return 1 ;;
    # die je-Teil-Profil-Dateien — dem Gemeinsam-Teil genommen (sie liegen je
    # Varianten in je_datei); gen.go/arch.go treten NICHT aus — sie traegt der
    # Gemeinsam-Teil ueber seine Aufnahme-Zeile, deklariert in GEN_GEMEINSAM
    ./internal/gen/golang.go | ./internal/gen/cpp.go | ./internal/gen/kotlin.go | ./internal/gen/jvm.go | ./internal/gen/java.go | ./internal/gen/java_hexslice.go | ./internal/gen/python.go | ./internal/gen/python_hexslice.go | ./internal/gen/csharp.go | ./internal/gen/csharp_hexslice.go) return 1 ;;
    # der Gemeinsam-Teil: Traeger-Quelle, Baseline, Treiber (Festlegung 2)
    ./cmd/* | ./internal/* | ./.harness/baseline/* | ./harness/tools/full-smoke.sh | ./harness/tools/full-smoke-skip.sh | ./harness/tools/handbuch-baum.sh) return 0 ;;
    *) return 1 ;;
  esac
}

# je_datei <pfad ./-frei> — die Profil-Zuordnung der Tafel: je Datei ihre
# Varianten (Festlegung 2), getrennt mit :. Eine Datei ohne Zeile ist nicht
# zugeordnet — pruefe faellt ueber ihr rot.
je_varianten() {
  local f="./$1"
  case "$f" in
    ./internal/gen/golang.go) printf 'go:sprachlos\n' ;;
    ./internal/gen/cpp.go) printf 'cpp\n' ;;
    ./internal/gen/kotlin.go) printf 'kotlin\n' ;;
    ./internal/gen/jvm.go) printf 'kotlin:java\n' ;;
    ./internal/gen/java.go) printf 'java\n' ;;
    ./internal/gen/java_hexslice.go) printf 'java\n' ;;
    ./internal/gen/python.go) printf 'python\n' ;;
    ./internal/gen/python_hexslice.go) printf 'python\n' ;;
    ./internal/gen/csharp.go) printf 'csharp\n' ;;
    ./internal/gen/csharp_hexslice.go) printf 'csharp\n' ;;
    *) return 1 ;;
  esac
}

# in_jeteil <variante> <pfad ./-frei> — der je-Teil der Variante aus derselben
# einen Zuordnung je_datei. Nur Gen-Dateien laufen je_datei — jeder andere Pfad
# tritt hier aus, ohne die Zuordnung zu fragen.
in_jeteil() {
  local v="$1" f="$2" z teil
  case "$f" in
    internal/gen/*.go) ;;
    *) return 1 ;;
  esac
  case "$f" in
    *_test.go | */testdata/*) return 1 ;;
  esac
  z="$(je_varianten "$f")" || return 1
  for teil in ${z//:/ }; do
    [ "$teil" = "$v" ] && return 0
  done
  return 1
}

# in_menge <variante> <pfad ./-frei> — die Tafel-Menge der Variante: Gemeinsam-Teil
# oder je-Teil (Festlegung 2).
in_menge() {
  in_gemeinsam "$2" && return 0
  in_jeteil "$1" "$2"
}

# baum_laden — der Walk in ./-freien, C-sortierten Zeilen (Form gates-keys.sh);
# hermetisch `find` statt git.
baum_laden() {
  DATEIEN=()
  local top
  if top="$(git -C "$WURZEL" rev-parse --show-toplevel 2>/dev/null)" \
     && [ "$top" = "$(cd "$WURZEL" && pwd)" ]; then
    mapfile -t DATEIEN < <(git -C "$WURZEL" ls-files --cached --others --exclude-standard | LC_ALL=C sort)
  else
    mapfile -t DATEIEN < <(
      (
        cd "$WURZEL"
        find . -name .git -prune -o \( -type f -o -type l \) -print
      ) | sed 's|^\./||' | LC_ALL=C sort
    )
  fi
  if [ "${#DATEIEN[@]}" -eq 0 ]; then
    printf 'full-smoke-varianten: der Walk ist leer\n' >&2
    return 1
  fi
}

# menge_of <variante> — die Tafel-Menge der Variante ueber dem geladenen Walk.
menge_of() {
  local v="$1" f
  for f in "${DATEIEN[@]}"; do
    if in_menge "$v" "$f"; then
      printf '%s\n' "$f"
    fi
  done
}

# schluessel_form <variante> — dieselbe Zeilenform wie gates-keys.sh/working-tree-hash.sh:
# je Datei `sha256sum … <pfad>`, Links als LINK-Zeile, fehlende Dateien als GONE.
schluessel_form() {
  local v="$1" f
  local datei=()
  for f in "${DATEIEN[@]}"; do
    in_menge "$v" "$f" || continue
    if [ -L "$f" ]; then
      printf 'LINK %s -> %s\n' "$f" "$(readlink -- "$f")"
    elif [ -f "$f" ]; then
      datei+=("$f")
    else
      printf 'GONE %s\n' "$f"
    fi
  done
  if [ "${#datei[@]}" -gt 0 ]; then
    sha256sum -- "${datei[@]}"
  fi
}

# Haupt — die Wurzel loesen, den Modus fahren.
WURZEL=""
MODES=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --wurzel)
      if [ "$#" -lt 2 ]; then
        printf 'full-smoke-varianten: --wurzel braucht einen Pfad\n' >&2
        exit 2
      fi
      WURZEL="$2"
      shift 2
      ;;
    --wurzel=*)
      WURZEL="${1#--wurzel=}"
      shift
      ;;
    *)
      MODES+=("$1")
      shift
      ;;
  esac
done
if [ "${#MODES[@]}" -eq 0 ]; then
  printf 'full-smoke-varianten: Modus fehlt (menge <variante> | hash <variante> | alle | pruefe)\n' >&2
  exit 2
fi

if [ -z "$WURZEL" ]; then
  if WURZEL="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    :
  else
    WURZEL="$PWD"
  fi
fi
cd "$WURZEL"

mode="${MODES[0]}"
rest=("${MODES[@]:1}")

case "$mode" in
  pruefe)
    baum_laden
    rot=0
    for f in "${DATEIEN[@]}"; do
      case "$f" in
        internal/gen/*.go) ;;
        *) continue ;;
      esac
      case "$f" in
        *_test.go | */testdata/*) continue ;;
      esac
      if je_varianten "$f" >/dev/null; then
        continue
      fi
      ok=0
      for g in "${GEN_GEMEINSAM[@]}"; do
        [ "./$f" = "$g" ] && ok=1 && break
      done
      if [ "$ok" -ne 1 ]; then
        printf 'full-smoke-varianten: nicht zugeordnet: %s — Tafel-Zeile je-Teil oder GEN_GEMEINSAM deklarieren (ADR-0113 Festlegung 2)\n' "$f" >&2
        rot=1
      fi
    done
    if [ "$rot" -ne 0 ]; then
      exit 1
    fi
    exit 0
    ;;
esac

baum_laden

case "$mode" in
  menge)
    if [ "${#rest[@]}" -ne 1 ]; then
      printf 'full-smoke-varianten: menge braucht genau eine Variante\n' >&2
      exit 2
    fi
    variante_bekannt "${rest[0]}" || exit 1
    menge_of "${rest[0]}"
    ;;
  hash)
    if [ "${#rest[@]}" -ne 1 ]; then
      printf 'full-smoke-varianten: hash braucht genau eine Variante\n' >&2
      exit 2
    fi
    variante_bekannt "${rest[0]}" || exit 1
    form="$(schluessel_form "${rest[0]}")"
    printf '%s\n' "$form" | sha256sum | awk '{print $1}'
    ;;
  alle)
    for v in "${VARIANTEN[@]}"; do
      form="$(schluessel_form "$v")"
      if [ -z "$form" ]; then
        printf 'full-smoke-varianten: leere Menge fuer %s — kein Key (fail-closed, MR-017)\n' "$v" >&2
        exit 1
      fi
      printf '%s %s\n' "$v" "$(printf '%s\n' "$form" | sha256sum | awk '{print $1}')"
    done
    ;;
  *)
    printf 'full-smoke-varianten: unbekannter Modus: %s\n' "$mode" >&2
    exit 2
    ;;
esac

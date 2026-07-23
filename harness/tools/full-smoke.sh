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

GO_VERSION="${GO_VERSION:-1.26.4}"
tmpbin="$(mktemp -d)"
tmprepo="$(mktemp -d)"
tmprepo_doc="$(mktemp -d)"
cleanup() { rm -rf "$tmpbin" "$tmprepo" "$tmprepo_doc"; }
trap cleanup EXIT
chmod 755 "$tmprepo_doc"
# mktemp -d liefert 0700; der d-check-Container laeuft als Nicht-Root und kann den
# 0700-Mount nicht traversieren. Ein echtes Adopter-Git-Repo hat 0755.
chmod 755 "$tmprepo"

echo "full-smoke: 1/3 natives Release-Binary auf den Host extrahieren (make artifact) ..."
make artifact DEST="$tmpbin" GO_VERSION="$GO_VERSION"

echo "full-smoke: 2/3 Bootstrap (--lang go --name full-smoke) in ein leeres tmp-Repo ..."
( cd "$tmprepo" && "$tmpbin/ai-harness-init" --lang go --name full-smoke )

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

# slice-032 (LH-FA-06/LH-QA-03): der emittierte Command-Guard muss real greifen —
# nicht nur praesent sein. Wir fuettern ihn mit Hook-JSON: die go-Toolchain (BLOCKED-
# Set --lang go) wird geblockt, ein make-Target durchgelassen. Das belegt zugleich
# den awk-Pfad (tools/harness/, relativ zu BASH_SOURCE aufgeloest) und dass Guard +
# Extraktor mit bash + awk auskommen (kein node/jq). Guard laeuft mit set -e; ein
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
git init -q "$tmprepo_doc"
echo "full-smoke: doc-only im Ziel: make -j gates (docs-check + baseline-verify + record-gates, KEIN Code-Gate) ..."
doc_rc=0
doc_out="$( make -j -C "$tmprepo_doc" gates 2>&1 )" || doc_rc=$?
printf '%s\n' "$doc_out"
if [ "$doc_rc" -ne 0 ]; then
	echo "full-smoke: FEHLER — sprachloser make gates ist NICHT Exit 0 (doc-only-Gate verletzt, LH-FA-01/slice-035)." >&2
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

# slice-038 (ADR-0007 Idempotenz-Klassifikation): ein ZWEITER Init-Lauf ist IDEMPOTENT
# (Exit 0 statt Kollisions-Refuse). Konvergente Dateien (tool-Infra) werden kanonisch neu
# geschrieben (heilen Drift); skip-if-present-Dateien (Adopter-Boden) bleiben unberuehrt.
echo "full-smoke: Idempotenz — README driften (skip-if-present) + Makefile driften (konvergent), dann 2. Init-Lauf ..."
printf '\n# adopter-gewachsen\n' >> "$tmprepo/README.md"   # skip-if-present: MUSS bleiben
readme_before="$(cat "$tmprepo/README.md")"
printf '\n# drift\n' >> "$tmprepo/Makefile"                # konvergent: MUSS geheilt werden
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
if grep -q '# drift' "$tmprepo/Makefile"; then
	echo "full-smoke: FEHLER — 2. Lauf heilte die Makefile-Drift NICHT (konvergent verletzt, slice-038)." >&2
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
echo "full-smoke: OK — IDEMPOTENT (slice-038): 2. Init-Lauf Exit 0, README (skip-if-present) unberuehrt, Makefile-Drift (konvergent) geheilt; sprachloser Re-Lauf prunt kein add-lang-Fragment (kein Prune)."

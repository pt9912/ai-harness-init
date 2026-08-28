# d-check.mk — Doku-Referenz-Gate via d-check. Abgeleitet aus `d-check --print-mk`
# (v0.65.0) und adaptiert (MR-010/MR-011/MR-012/MR-024/MR-027):
#   * das Befund-Gate heißt `docs-check` statt `doc-check` (Ziel-Form-/modul-13-
#     Konsistenz; als EINZIGES Target in `make gates` + AGENTS/README behauptet);
#   * DCHECK_DIGEST ist auf den v0.65.0-Release-Digest GEPINNT (das Tool liefert es
#     leer) — strikte Reproduzierbarkeit (LH-QA-02);
#   * die advisory-Targets (`doc-trace`/`doc-doctor`/…) bleiben SONST verbatim vom Tool
#     (`doc-help` ist der eine Handgriff, s. u.) und sind NICHT als Gate behauptet —
#     verfügbar wie `regelwerk-check`, kein halluziniertes Gate (LH-QA-01). Die
#     opt-in-Module `citations` (18., v0.50.0), `sources` (19., Netz, v0.51.0) und
#     `structure` (20., v0.57.0, Target `doc-structure`) sind in `.d-check.yml` NICHT
#     aktiviert — was NICHT heisst, dass es keinen Lauf gibt: `sources` faehrt in
#     `make regelwerk-check` (`--enable sources`, mit Netz, nicht in `make gates`),
#     `structure` in `doc-structure`. „Nicht aktiviert" meint die Modul-Liste des
#     Befund-Gates.
#     Von den sechs fokussierten advisory-Recipes
#     disablen FUENF alle drei (verbatim vom Tool) — das sechste IST `doc-structure` und
#     enabled sein Modul, wie jedes advisory-Target ohne Platz in `make gates`.
#     Die Zeilenreferenz-Prüfung `codepaths.check-lines` ist in `.d-check.yml`
#     aktiviert (additive Härtung, MR-011).
# VERENGUNG MIT v0.65.0, zwei Achsen, an einer Sonde gemessen statt dem CHANGELOG
# geglaubt: ein `d-check:ignore` unterdrueckt nur noch, wenn es (a) in einem echten
# HTML-Kommentar steht UND (b) nicht in Inline-Code eingeschlossen ist. Vier Lagen ueber
# einem toten Codepath, beide Digests, Kopie ausserhalb des Repos:
#   `<!-- d-check:ignore -->`     v0.62.0 unterdrueckt | v0.65.0 unterdrueckt
#   blanke Prosa `d-check:ignore` v0.62.0 unterdrueckt | v0.65.0 MELDET
#   Kommentar in Inline-Code      v0.62.0 unterdrueckt | v0.65.0 MELDET
#   ohne Marker (Kontrolle)       beide melden
# UEBER DIESEM BAUM KOSTET DAS NICHTS, und der Grund ist nicht „wir fuehren keine solchen
# Marker" — es gibt sie, sie tragen nur nicht. WAS DAS MISST, IST DER LAUF SELBST: `make
# docs-check` faehrt den gepinnten v0.65.0 und ist gruen, und jeder `make gates`-Lauf prueft
# es neu. DAS IST FALSIFIZIERBAR, nicht tautologisch: traegt ein Marker in einer der zwei
# nicht mehr honorierten Formen einen echten Befund, wird `docs-check` rot — gemessen an
# einer Sonde ueber einer Kopie, blanke Prosa ueber unverlinkter Kennung, `1 Befund`.
# Hier steht dazu bewusst KEINE Zahl: die Marker-Menge waechst mit dem Bestand.
# Wer zaehlt, schneidet ueber den PFAD statt ueber den Text und summiert:
#   `git grep -h 'd-check:ignore' -- '*.md' ':!.harness/baseline' | wc -l`
# `grep -v '.harness/baseline'` verwirft auch Zeilen, die den Pfad bloss NENNEN, und
# `git grep -c` gibt `pfad:anzahl` je Datei aus statt einer Summe. Beide liefern eine
# plausible Zahl ohne Fehler — ein Kommando neben einer Zahl belegt sie erst, wenn es den
# Gegenstand schneidet.
# Einbinden: `include d-check.mk`; eine eigene .d-check.yml danebenlegen.
# NEU-ERZEUGUNG: VIER Handgriffe. Abzaehlbar — der Digest steht literal, weil `$(DCHECK_REF)`
# in einem Kommentar keine Shell-Variable ist und wortwoertlich gefahren still `1` liefert:
#   diff <(docker run --rm --network none \
#     ghcr.io/pt9912/d-check@sha256:5ea03abe7918381c68203d8ac078a78d0d4ab91b5478e87c66b5a7b4fda41288 \
#     --print-mk) d-check.mk | grep -c '^[0-9]'
#   1. dieser Adopter-Kopf (das Tool liefert ihn nicht),
#   2. DCHECK_DIGEST pinnen (das Tool liefert es leer),
#   3. `.PHONY`- und Target-Zeile `doc-check` -> `docs-check`, Hilfetext erweitert,
#   4. `doc-help` zieht mit (`^docs?-` statt `^doc-`, sonst faellt docs-check aus der Liste).
DCHECK_IMAGE ?= ghcr.io/pt9912/d-check:v0.65.0
DCHECK_DIGEST ?= sha256:5ea03abe7918381c68203d8ac078a78d0d4ab91b5478e87c66b5a7b4fda41288
# TRACE_FLAGS: optionale Flags für die RTM-Targets (z. B. --json).
TRACE_FLAGS ?=

# Ein gesetzter DCHECK_DIGEST sticht den Tag von DCHECK_IMAGE.
ifeq ($(strip $(DCHECK_DIGEST)),)
DCHECK_REF := $(DCHECK_IMAGE)
else
DCHECK_REF := ghcr.io/pt9912/d-check@$(DCHECK_DIGEST)
endif

.PHONY: docs-check
docs-check: ## Doku-Referenzen prüfen (Befund-Gate; links/anchors/ids/codepaths laut .d-check.yml) — netzlos
	docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF)

.PHONY: doc-trace
doc-trace: ## Requirements Traceability Matrix auf stdout (advisory, DC-FA-CLI-009)
	docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --trace $(TRACE_FLAGS)

.PHONY: doc-complete
doc-complete: ## Vollständigkeits-Gate: Requirements-Waise ⇒ Exit 1 (DC-FA-CLI-011)
	docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --trace --require-complete $(TRACE_FLAGS)

.PHONY: doc-doctor
doc-doctor: ## erklärende Diagnose mit Fix-Kandidaten (DC-FA-CLI-007)
	docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --doctor

.PHONY: doc-repair
doc-repair: ## Reparatur-Patch (unified diff) auf stdout, git-apply-rein (DC-FA-CLI-008)
	@docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --repair

.PHONY: doc-immutable
doc-immutable: ## Doc-/ADR-Immutabilität via git-Diff (Modul vcs); RANGE=base..head oder STAGED=1 (DC-FA-VCS-001)
	docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --enable vcs --disable links --disable anchors --disable ids --disable matrix --disable external --disable codepaths --disable spans --disable hostpaths --disable diagrams --disable versions --disable pins --disable immutable --disable commits --disable planning --disable tracked --disable targets --disable citations --disable sources --disable structure $(if $(STAGED),--staged,--range $(RANGE))

.PHONY: doc-commits
doc-commits: ## Commit-Message-Traceability via Modul commits; RANGE=base..head (DC-FA-COMMITS-001)
	docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --enable commits --disable links --disable anchors --disable ids --disable matrix --disable external --disable codepaths --disable spans --disable hostpaths --disable diagrams --disable versions --disable pins --disable immutable --disable vcs --disable planning --disable tracked --disable targets --disable citations --disable sources --disable structure --range $(RANGE)

.PHONY: doc-planning
doc-planning: ## Planning-Lifecycle-Konsistenz (Roadmap <-> in-progress) via Modul planning; hermetisch, ohne Range (DC-FA-PLAN-001)
	docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --enable planning --disable links --disable anchors --disable ids --disable matrix --disable external --disable codepaths --disable spans --disable hostpaths --disable diagrams --disable versions --disable pins --disable immutable --disable vcs --disable commits --disable tracked --disable targets --disable citations --disable sources --disable structure

.PHONY: doc-tracked
doc-tracked: ## Getrackt-Status aufloesbarer Referenz-Ziele via Modul tracked; braucht .git im Mount, ohne Range (DC-FA-TRK-001)
	docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --enable tracked --disable links --disable anchors --disable ids --disable matrix --disable external --disable codepaths --disable spans --disable hostpaths --disable diagrams --disable versions --disable pins --disable immutable --disable vcs --disable commits --disable planning --disable targets --disable citations --disable sources --disable structure

.PHONY: doc-targets
doc-targets: ## Deklarations-Konsistenz Doku<->Build-Targets via Modul targets; hermetisch, ohne Range (DC-FA-TGT-001)
	docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --enable targets --disable links --disable anchors --disable ids --disable matrix --disable external --disable codepaths --disable spans --disable hostpaths --disable diagrams --disable versions --disable pins --disable immutable --disable vcs --disable commits --disable planning --disable tracked --disable citations --disable sources --disable structure

.PHONY: doc-structure
doc-structure: ## Struktur-Invarianten innerhalb der Dokumente via Modul structure; hermetisch, ohne Range (DC-FA-STRUCT-001)
	docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --enable structure --disable links --disable anchors --disable ids --disable matrix --disable external --disable codepaths --disable spans --disable hostpaths --disable diagrams --disable versions --disable pins --disable immutable --disable vcs --disable commits --disable planning --disable tracked --disable targets --disable citations --disable sources

.PHONY: doc-help
doc-help: ## diese Liste der docs-check-/doc-*-Targets
	@grep -hE '^docs?-[a-z-]+:.*## ' $(MAKEFILE_LIST) | sort | sed -E 's/:.*## /  /'

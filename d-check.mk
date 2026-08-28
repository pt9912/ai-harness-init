# d-check.mk — Doku-Referenz-Gate via d-check. Abgeleitet aus `d-check --print-mk`
# (v0.65.0) und adaptiert (MR-010/MR-011/MR-012/MR-024/MR-027):
#   * das Befund-Gate heißt `docs-check` statt `doc-check` (Ziel-Form-/modul-13-
#     Konsistenz; als EINZIGES Target in `make gates` + AGENTS/README behauptet);
#   * DCHECK_DIGEST ist auf den v0.65.0-Release-Digest GEPINNT (das Tool liefert es
#     leer) — strikte Reproduzierbarkeit (LH-QA-02);
#   * die advisory-Targets (`doc-trace`/`doc-doctor`/…) bleiben verbatim vom Tool und
#     sind NICHT als Gate behauptet — verfügbar wie `regelwerk-check`, kein
#     halluziniertes Gate (LH-QA-01). Die opt-in-Module `citations` (18., v0.50.0),
#     `sources` (19., Netz, v0.51.0) und `structure` (20., v0.57.0, Target
#     `doc-structure`) sind in `.d-check.yml` NICHT aktiviert — `sources` faehrt trotzdem,
#     naemlich in `make regelwerk-check` (Makefile, `--enable sources`, mit Netz, NICHT in
#     `make gates`); `structure` in `doc-structure`. „Nicht aktiviert" heisst hier: nicht in
#     der Modul-Liste des Befund-Gates, nicht: es gibt keinen Lauf.
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
# es neu. Hier steht dazu bewusst KEINE Zahl. Die Marker-Menge waechst mit dem Bestand; eine
# eingefrorene Zaehlung an dieser Stelle war schon am Tag ihrer Niederschrift falsch — sie
# war es (slice-128 DoD (2), MR-025 Setzung 2).
# Wer doch zaehlt, schneidet ueber den PFAD und nicht ueber den Text:
# `git grep -c 'd-check:ignore' -- '*.md' ':!.harness/baseline'`. Ein
# `grep -v '.harness/baseline'` verwirft auch Zeilen, die den Pfad bloss NENNEN, und liefert
# darum reproduzierbar zu wenig — ein Kommando neben einer Zahl belegt sie erst, wenn das
# Kommando den Gegenstand schneidet.
# DASS DIE MENGE UEBERHAUPT TRAEGT, ist gegengemessen und nicht angenommen: mit entwerteten
# Markern melden BEIDE Versionen dieselbe Befundmenge, `diff` der sortierten Ausgaben leer.
# Die Befundzahl selbst waechst mit dem Bestand und steht darum in MR-027 an ihrem Stand,
# nicht hier.
# Einbinden: `include d-check.mk`; eine eigene .d-check.yml danebenlegen.
# NEU-ERZEUGUNG, und es sind VIER Handgriffe, nicht zwei — abzaehlbar mit
# `diff <(docker run --rm --network none $(DCHECK_REF) --print-mk) d-check.mk | grep -c '^[0-9]'`:
#   1. dieser Adopter-Kopf (das Tool liefert ihn nicht),
#   2. DCHECK_DIGEST pinnen (das Tool liefert es leer),
#   3. `doc-check` -> `docs-check` samt seiner Hilfe-Zeile,
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

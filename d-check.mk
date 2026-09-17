# d-check.mk — Doku-Referenz-Gate via d-check. Abgeleitet aus `d-check --print-mk`
# (v0.76.3) und adaptiert (MR-010/MR-011/MR-012/MR-024/MR-027/MR-052/MR-061/MR-062/MR-064/MR-066):
#   * das Befund-Gate heißt `docs-check` statt `doc-check` (Ziel-Form-/modul-13-
#     Konsistenz; als EINZIGES Target in `make gates` + AGENTS/README behauptet);
#   * DCHECK_DIGEST ist auf den v0.76.3-Release-Digest GEPINNT (das Tool liefert es
#     leer) — strikte Reproduzierbarkeit (LH-QA-02);
#   * die advisory-Targets (`doc-trace`/`doc-doctor`/…) bleiben SONST verbatim vom Tool
#     (`doc-help` ist der eine Handgriff, s. u.) und sind NICHT als Gate behauptet —
#     verfügbar wie `regelwerk-check`, kein halluziniertes Gate (LH-QA-01). Die
#     opt-in-Module `citations` (18., v0.50.0), `sources` (19., Netz, v0.51.0),
#     `workflows` (21., v0.67.0), `reviews` (22., v0.73.0) und `mentions` (23., v0.75.0)
#     sind in `.d-check.yml` NICHT aktiviert — was NICHT heisst, dass es keinen Lauf
#     gibt: `sources` faehrt in `make regelwerk-check` (`--enable sources`, mit Netz,
#     nicht in `make gates`); `workflows`/`reviews`/`mentions` haben kein eigenes
#     Recipe. „Nicht aktiviert" meint die Modul-Liste des Befund-Gates.
#     Das opt-in-Modul `structure` (20., v0.57.0) IST aktiviert: `.d-check.yml` fuehrt
#     es in `modules:` und einen `structure`-Block mit der elften Bedingung
#     `open-tasks-require-marker` (v0.76.0, Grund-Code
#     `section-open-tasks-marker-missing`); `docs-check` faehrt es, `doc-structure`
#     faehrt es allein.
#     Von den sechs fokussierten advisory-Recipes disablen FUENF alle SECHS
#     opt-in-Module (verbatim vom Tool) — das sechste IST `doc-structure` und
#     enabled sein eigenes Modul, wie jedes advisory-Target ohne Platz in `make gates`.
#     Die Zeilenreferenz-Prüfung `codepaths.check-lines` ist in `.d-check.yml`
#     aktiviert (additive Härtung, MR-011).
# VERENGTES MARKER-VERHALTEN: ein `d-check:ignore` unterdrueckt nur, wenn es
# (a) in einem echten HTML-Kommentar steht UND (b) nicht in Inline-Code
# eingeschlossen ist. Vier Lagen ueber einem toten Codepath (Messung und Stand
# dieser Tabelle und der Sonde unten: MR-027):
#   `<!-- d-check:ignore -->`      unterdrueckt
#   blanke Prosa `d-check:ignore`  MELDET
#   Kommentar in Inline-Code       MELDET
#   ohne Marker (Kontrolle)        meldet
# UEBER DIESEM BAUM KOSTET DAS NICHTS, und der Grund ist nicht „wir fuehren keine solchen
# Marker" — es gibt sie, sie tragen nur nicht. WAS DAS MISST, IST DER LAUF SELBST: `make
# docs-check` faehrt den gepinnten Digest und ist gruen, und jeder `make gates`-Lauf prueft
# es neu. DAS IST FALSIFIZIERBAR, nicht tautologisch: traegt ein Marker in einer der zwei
# nicht honorierten Formen einen echten Befund, wird `docs-check` rot.
# Hier steht dazu bewusst KEINE Zahl: die Marker-Menge waechst mit dem Bestand.
# Wer zaehlt, schneidet ueber den PFAD statt ueber den Text und summiert:
#   `git grep -h 'd-check:ignore' -- '*.md' ':!.harness/baseline' | wc -l`
# `grep -v '.harness/baseline'` verwirft auch Zeilen, die den Pfad bloss NENNEN, und
# `git grep -c` gibt `pfad:anzahl` je Datei aus statt einer Summe. Beide liefern eine
# plausible Zahl ohne Fehler — ein Kommando neben einer Zahl belegt sie erst, wenn es den
# Gegenstand schneidet.
# BEFUND-ZEILEN TRAGEN EINE VIERTE, TAB-GETRENNTE SPALTE, AUSSER DENEN VON `spans`
# (`span-unclosed`, `span-nested-link`, `fence-unclosed`: drei Spalten; Messung und Stand: MR-063):
# den Klartext des Grundes (`target-missing` -> „Linkziel existiert nicht"). Den Grund-Code
# liefert in beiden Faellen die dritte Spalte (`awk -F'\t' '{print $3}'`); die letzte
# (`$NF`) gibt bei vierspaltigen Zeilen den Klartext, bei dreispaltigen den Code. Kein
# Werkzeug dieses Repos liest `$NF` als Grund-Code:
#   git grep -nF '$NF' -- ':!d-check.mk' ':!*.md' ':!.harness'      # kein Treffer
# DIE ZUSAMMENFASSUNG AUF STDERR KANN VOR DER ZAEHL-ZEILE `d-check: N Datei(en) geprüft,
# M Befund(e)` WEITERE `d-check: …`-ZEILEN TRAGEN (`summary.notes`, v0.75.0; gefuellt nur
# vom Modul `mentions`, das hier nicht aktiv ist; MR-061). Die Zaehl-Zeile bleibt die letzte.
# Einbinden: `include d-check.mk`; eine eigene .d-check.yml danebenlegen.
# NEU-ERZEUGUNG: FUENF Handgriffe, SECHS Diff-Hunks — das Kommando zaehlt HUNKS, nicht
# Handgriffe: Handgriff 5 aendert jedes Ziel seiner Menge, und je Ziel trennt die
# unveraenderte `docker run`-Zeile die geaenderte Ziel-/Hilfetext-Zeile von der angehaengten
# `@echo`-Zeile -- macht 2 Hunks je Ziel; die Menge ist `doc-tracked`, die Handgriffe 1-4
# liefern je einen, zusammen 6.
# Der Digest steht literal, weil `$(DCHECK_REF)` in einem Kommentar keine Shell-Variable ist
# und wortwoertlich gefahren still `1` liefert:
#   diff <(docker run --rm --network none \
#     ghcr.io/pt9912/d-check@sha256:2f2f24601251d6b6c1dda13c4a847039a88abfd7e2de508d64180be97bfd2af0 \
#     --print-mk) d-check.mk | grep -c '^[0-9]'                                    # 6
#   1. dieser Adopter-Kopf (das Tool liefert ihn nicht),
#   2. DCHECK_DIGEST pinnen (das Tool liefert es leer),
#   3. `.PHONY`- und Target-Zeile `doc-check` -> `docs-check`, Hilfetext erweitert,
#   4. `doc-help` zieht mit (`^docs?-` statt `^doc-`, sonst faellt docs-check aus der Liste),
#   5. die Marke an jedem Ziel, dessen `--enable`-Modul in `.d-check.yml` keinen eigenen
#      Block hat (Hilfetext-Anhang UND Ausgabe-Zeile `.d-check.yml fuehrt fuer dieses Modul
#      keinen eigenen Block, …` — der Generator liefert keins von beidem; MR-062). Die Menge
#      leitet test/doc-block-marke-wiring.bats aus beiden Dateien ab.
DCHECK_IMAGE ?= ghcr.io/pt9912/d-check:v0.76.3
DCHECK_DIGEST ?= sha256:2f2f24601251d6b6c1dda13c4a847039a88abfd7e2de508d64180be97bfd2af0
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
	docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --enable vcs --disable links --disable anchors --disable ids --disable matrix --disable external --disable codepaths --disable spans --disable hostpaths --disable diagrams --disable versions --disable pins --disable immutable --disable commits --disable planning --disable tracked --disable targets --disable citations --disable sources --disable structure --disable workflows --disable reviews --disable mentions $(if $(STAGED),--staged,--range $(RANGE))

.PHONY: doc-commits
doc-commits: ## Commit-Message-Traceability via Modul commits; RANGE=base..head (DC-FA-COMMITS-001)
	docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --enable commits --disable links --disable anchors --disable ids --disable matrix --disable external --disable codepaths --disable spans --disable hostpaths --disable diagrams --disable versions --disable pins --disable immutable --disable vcs --disable planning --disable tracked --disable targets --disable citations --disable sources --disable structure --disable workflows --disable reviews --disable mentions --range $(RANGE)

.PHONY: doc-planning
doc-planning: ## Planning-Lifecycle-Konsistenz (Roadmap <-> in-progress) via Modul planning; hermetisch, ohne Range (DC-FA-PLAN-001)
	docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --enable planning --disable links --disable anchors --disable ids --disable matrix --disable external --disable codepaths --disable spans --disable hostpaths --disable diagrams --disable versions --disable pins --disable immutable --disable vcs --disable commits --disable tracked --disable targets --disable citations --disable sources --disable structure --disable workflows --disable reviews --disable mentions

.PHONY: doc-tracked
doc-tracked: ## Getrackt-Status aufloesbarer Referenz-Ziele via Modul tracked; braucht .git im Mount, ohne Range (DC-FA-TRK-001) -- .d-check.yml fuehrt fuer dieses Modul keinen eigenen Block, siehe harness/sensors/doc-tracked.md bzw. harness/sensors/doc-structure.md
	docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --enable tracked --disable links --disable anchors --disable ids --disable matrix --disable external --disable codepaths --disable spans --disable hostpaths --disable diagrams --disable versions --disable pins --disable immutable --disable vcs --disable commits --disable planning --disable targets --disable citations --disable sources --disable structure --disable workflows --disable reviews --disable mentions
	@echo '.d-check.yml fuehrt fuer dieses Modul keinen eigenen Block, siehe harness/sensors/doc-tracked.md bzw. harness/sensors/doc-structure.md'

.PHONY: doc-targets
doc-targets: ## Deklarations-Konsistenz Doku<->Build-Targets via Modul targets; hermetisch, ohne Range (DC-FA-TGT-001)
	docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --enable targets --disable links --disable anchors --disable ids --disable matrix --disable external --disable codepaths --disable spans --disable hostpaths --disable diagrams --disable versions --disable pins --disable immutable --disable vcs --disable commits --disable planning --disable tracked --disable citations --disable sources --disable structure --disable workflows --disable reviews --disable mentions

.PHONY: doc-structure
doc-structure: ## Struktur-Invarianten innerhalb der Dokumente via Modul structure; hermetisch, ohne Range (DC-FA-STRUCT-001)
	docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --enable structure --disable links --disable anchors --disable ids --disable matrix --disable external --disable codepaths --disable spans --disable hostpaths --disable diagrams --disable versions --disable pins --disable immutable --disable vcs --disable commits --disable planning --disable tracked --disable targets --disable citations --disable sources --disable workflows --disable reviews --disable mentions

.PHONY: doc-usage
doc-usage: ## Aufruf und Optionen von d-check selbst (--help)
	@docker run --rm --network none -v "$(CURDIR):/repo:ro" $(DCHECK_REF) --help

.PHONY: doc-help
doc-help: ## diese Liste der docs-check-/doc-*-Targets
	@grep -hE '^docs?-[a-z-]+:.*## ' $(MAKEFILE_LIST) | sort | sed -E 's/:.*## /  /'

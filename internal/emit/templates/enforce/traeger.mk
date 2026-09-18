# harness/mk/traeger.mk — Fragment des Traeger-Fetch, emittiert von ai-harness-init.
# EIN KOMMANDO, KEIN GATE.
#
# Es liegt im Fragment-Verzeichnis wie die Gate-Fragmente, haengt aber NICHTS an
# GATE_CHECKS und steht in keiner Prerequisite-Kette — auch nicht an archive-welle:
# dessen Fehlt-Fall ist die Zusage "Exit 0, nennt das Fehlende, schreibt nichts", und
# ein Fetch davor wuerde sie still aendern (ADR-0058 Festlegung 3 und Folgepflicht 5).
# Der Fetch ist der AUSDRUECKLICHE Weg aus dem Zustand, den jene Meldung benennt.
#
# Der Traeger liegt im gitignorierten Zustands-Bereich: ein frischer Klon hat ihn
# nicht. Dieses Kommando holt ihn aus dem gepinnten Release nach — sha256 je Asset
# verifiziert VOR der Ablage, eine Abweichung bricht ab, ohne den Traeger zu legen;
# der Transport laeuft im gepinnten Bild, nicht auf dem Host (LH-QA-03). Netz braucht
# er an genau diesem Aufruf (MR-007-Muster); er laeuft nur auf ausdruecklichem Aufruf.
.PHONY: traeger-fetch

# DIE PINS (ADR-0058 Festlegung 1): Release-Tag und sha256 der sechs Assets der
# Plattform-Matrix (LH-QA-04), gespiegelt aus dem Dogfood-Makefile als
# ueberschreibbare Variablen; test/traeger-fetch.bats (im Werkzeug-Repo) haelt jede
# Stelle gegen das kanonische Makefile-Paar.
TRAEGER_TAG ?= v0.2.0
TRAEGER_SHA256_LINUX_AMD64 ?= 0a5851f40be317aa42394678253de99bfd1267a84218b85900b59f8031a42f5b
TRAEGER_SHA256_LINUX_ARM64 ?= e09fbcbf5a5872cb6b07d8ffc337f91f0d6645cdd8b60401ea806a083516f615
TRAEGER_SHA256_DARWIN_AMD64 ?= 2922d8b016215b6192434ffd311c50ce1b330ff25d62279d42dea25543b7c42e
TRAEGER_SHA256_DARWIN_ARM64 ?= 08ecf5b9c3f38d863871177f0ded59594faa4f56022f99592a28e3a66fc6520f
TRAEGER_SHA256_WINDOWS_AMD64 ?= 128485955fe3127f1572a358fbd52dd99954518aff5379802d7ddab806274b54
TRAEGER_SHA256_WINDOWS_ARM64 ?= 7ac98297bd5286b38f13a454c22a55eb84df13903238691cc5cb7fd55be013f7
TRAEGER_CARRIER ?= .harness/state/bin/ai-harness-init

export TRAEGER_TAG TRAEGER_SHA256_LINUX_AMD64 TRAEGER_SHA256_LINUX_ARM64 TRAEGER_SHA256_DARWIN_AMD64 TRAEGER_SHA256_DARWIN_ARM64 TRAEGER_SHA256_WINDOWS_AMD64 TRAEGER_SHA256_WINDOWS_ARM64 TRAEGER_CARRIER

traeger-fetch: ## Traeger aus dem gepinnten Release nachholen (braucht Netz) — NICHT in gates
	@bash tools/harness/traeger-fetch.sh
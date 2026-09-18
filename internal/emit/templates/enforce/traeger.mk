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
TRAEGER_TAG ?= v0.1.1
TRAEGER_SHA256_LINUX_AMD64 ?= 654041d9c7a198435c9b32067a1c938b358174c28905d05dd94b44016d88b0bc
TRAEGER_SHA256_LINUX_ARM64 ?= 7f637eb993c66e6dc373fef47f67cc03381674a45f1829fe9de21809bb23c7ec
TRAEGER_SHA256_DARWIN_AMD64 ?= e02bc2eb313df701b72b8223bb5fd43db40eec38fef9590323998d27f875fe6c
TRAEGER_SHA256_DARWIN_ARM64 ?= a6512e99c85c17e0beef407fe5568a5771ac1cb452e3d1b3a188032e19ad359b
TRAEGER_SHA256_WINDOWS_AMD64 ?= 18d406f4c619339c6556c5602fd86fbf630022199ac9ad52cd777d64839103e7
TRAEGER_SHA256_WINDOWS_ARM64 ?= 5cab3da5670069ad38dadb8a1497ffcf25faeb457199894721df0688dca8af0b
TRAEGER_CARRIER ?= .harness/state/bin/ai-harness-init

export TRAEGER_TAG TRAEGER_SHA256_LINUX_AMD64 TRAEGER_SHA256_LINUX_ARM64 TRAEGER_SHA256_DARWIN_AMD64 TRAEGER_SHA256_DARWIN_ARM64 TRAEGER_SHA256_WINDOWS_AMD64 TRAEGER_SHA256_WINDOWS_ARM64 TRAEGER_CARRIER

traeger-fetch: ## Traeger aus dem gepinnten Release nachholen (braucht Netz) — NICHT in gates
	@bash tools/harness/traeger-fetch.sh
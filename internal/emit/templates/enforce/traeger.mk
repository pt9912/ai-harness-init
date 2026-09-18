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
TRAEGER_SHA256_LINUX_AMD64 ?= 37c67efae72661b809ccf44de36ed14e72073238e4dcbf67e0324a4578f38cd3
TRAEGER_SHA256_LINUX_ARM64 ?= d751ddf961511e828ff6d8631acbfe91470aedc2609310262da38439ed8e19b5
TRAEGER_SHA256_DARWIN_AMD64 ?= a5ab19a32b743fe2108d2919c8ca6e887e6cf63028ce9b4009c9060d2bd63aad
TRAEGER_SHA256_DARWIN_ARM64 ?= 20f5fe1c15107594490642bc105fee071bb887ac1e5fdefa197cf05f00b3e896
TRAEGER_SHA256_WINDOWS_AMD64 ?= 1f8475d9873ba6663576ed2af24eaad72bbd24c2cfee2999b233b49adaea511e
TRAEGER_SHA256_WINDOWS_ARM64 ?= 0b4113c7527df001d2a32d7077181af906e08ffbf78f503b5e34dc0819525241
TRAEGER_CARRIER ?= .harness/state/bin/ai-harness-init

export TRAEGER_TAG TRAEGER_SHA256_LINUX_AMD64 TRAEGER_SHA256_LINUX_ARM64 TRAEGER_SHA256_DARWIN_AMD64 TRAEGER_SHA256_DARWIN_ARM64 TRAEGER_SHA256_WINDOWS_AMD64 TRAEGER_SHA256_WINDOWS_ARM64 TRAEGER_CARRIER

traeger-fetch: ## Traeger aus dem gepinnten Release nachholen (braucht Netz) — NICHT in gates
	@bash tools/harness/traeger-fetch.sh
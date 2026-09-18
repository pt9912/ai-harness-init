# harness/mk/selbstpruefung.mk — Fragment der Selbstpruefung der
# Durchsetzungsschicht, emittiert von ai-harness-init. EIN KOMMANDO, KEIN GATE.
#
# WARUM ES AN KEINER GATE-KETTE HAENGT: das Ziel legt fuer diese Pruefung einen
# eigenen Klon an und faehrt darin das Gate-Kommando. Haengte es an `gates`,
# fuehrte jeder Gate-Lauf einen Klon mit, und ein rotes Ergebnis waere nicht
# mehr vom roten Klon-Lauf zu unterscheiden. Es wird ausdruecklich gerufen.
#
# DREI MARKER, JE MIT BELEGUNG. Sie werden an das Skript durchgereicht und
# koennen am Aufruf gesetzt werden:
#   make selbstpruefung SELBSTPRUEFUNG_GATE='make baseline-verify'
# Der Lauf nennt in seiner ersten Zeile die Werte, mit denen er faehrt.
#
# ABHAENGIGKEIT. git, make und coreutils; was das Gate-Kommando braucht,
# bringt es selbst mit.
.PHONY: selbstpruefung

# Der Traeger im Klon — der Name gehoert git, das Verzeichnis dem Repo.
SELBSTPRUEFUNG_TRAEGER ?= .githooks/commit-msg
# Der eine Schritt zwischen liegendem und wirksamem Traeger.
SELBSTPRUEFUNG_AKTIVIERUNG ?= make hooks-install
# Das Kommando, das im Klon gruen laufen muss.
SELBSTPRUEFUNG_GATE ?= make gates

# Fehlt das Skript, sagt dieses Ziel das und bricht ab, statt auf ein
# fehlendes Programm zu zeigen.
selbstpruefung: ## die emittierte Durchsetzungsschicht auf einem frischen Klon selbst pruefen — KEIN Gate
	@test -x tools/harness/selbstpruefung.sh || { echo "selbstpruefung: tools/harness/selbstpruefung.sh liegt nicht ausfuehrbar — das Werkzeug legt sie bei jedem Lauf kanonisch ab; ein erneuter Lauf stellt sie her."; exit 2; }
	@SELBSTPRUEFUNG_TRAEGER="$(SELBSTPRUEFUNG_TRAEGER)" \
	 SELBSTPRUEFUNG_AKTIVIERUNG="$(SELBSTPRUEFUNG_AKTIVIERUNG)" \
	 SELBSTPRUEFUNG_GATE="$(SELBSTPRUEFUNG_GATE)" \
	 bash tools/harness/selbstpruefung.sh

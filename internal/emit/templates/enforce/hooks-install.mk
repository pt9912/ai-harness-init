# harness/mk/hooks-install.mk — Fragment des Commit-Kennungs-Waechters, emittiert
# von ai-harness-init. EIN KOMMANDO, KEIN GATE.
#
# DER TRAEGER LIEGT VERSIONIERT UNTER .githooks/commit-msg UND REIST MIT DEM KLON;
# SEINE AKTIVIERUNG TUT DAS NICHT. `core.hooksPath` ist lokale Konfiguration,
# dieses Ziel ist der eine Schritt dazwischen. Ein Klon ohne diesen Aufruf ist
# ungeprueft, und `git commit --no-verify` umgeht den Traeger auch danach — ein
# Stolperdraht, keine Sandbox.
#
# WAS DER TRAEGER NICHT ERREICHT. Die zweite Haelfte der Traceability-Zusage —
# das Doku-Update bei beruehrtem oeffentlichem Vertrag — ist von einem
# Commit-Waechter nicht mechanisch pruefbar und bleibt Arbeit des Committenden.
# Geprueft wird die ANWESENHEIT einer Kennung, nicht ihre Wahrheit: eine Message,
# die zusaetzlich einen nicht aufloesbaren Verweis nennt, geht mit derselben
# Kennung durch. Beide Grenzen stehen auch im Kopf von
# tools/harness/commit-msg-traceability.sh.
#
# WAS ER MITNIMMT. Er haengt am Commit und sieht jede Klasse, die `git` erzeugt —
# auch die Commits der Repo-Werkzeuge. `make slice-mv` und `make archive-welle`
# committen intern mit dem Slice- bzw. Welle-Namen; traegt er keine Kennung aus der
# Menge, faellt der Commit des Werkzeugs. Ein Repo, das diesen Traeger aktiviert,
# gibt seinen Werkzeug-Messages darum eine Kennung — sonst bricht sein eigenes
# Werkzeug an seinem eigenen Waechter.
#
# ABHAENGIGKEIT. Dieses Rezept ruft `git` — die zugelassene Host-Abhaengigkeit
# dieses Aufbaus; der Traeger selbst laeuft im Commit-Pfad und setzt weder Docker
# noch Netz noch ein Gate-Bild voraus.
.PHONY: hooks-install

# Das Verzeichnis des Traegers ist tool-eigen und wird bei jedem Bootstrap
# kanonisch neu geschrieben.
HOOKS_DIR ?= .githooks

# Fehlt der Traeger, sagt dieses Ziel das und bricht ab: `git config` haette sonst
# einen Pfad gesetzt, unter dem nichts liegt, und jeder Commit liefe ungeprueft
# durch, waehrend die Konfiguration einen Waechter behauptet (LH-QA-01).
# Das Ausfuehrrecht setzt das Rezept nach: git verwirft einen nicht ausfuehrbaren
# Hook still, und ein verlorenes Bit waere ein Waechter, der nur so aussieht.
hooks-install: ## den git-eigenen commit-msg-Traeger im Klon aktivieren (core.hooksPath) — KEIN Gate
	@test -f "$(HOOKS_DIR)/commit-msg" || { echo "hooks-install: $(HOOKS_DIR)/commit-msg liegt nicht — dieses Fragment aktiviert den Traeger, den der Bootstrap schreibt; ein erneuter Lauf des Werkzeugs legt ihn ab."; exit 2; }
	@test -x "$(HOOKS_DIR)/commit-msg" || chmod +x "$(HOOKS_DIR)/commit-msg"
	@git config core.hooksPath "$(HOOKS_DIR)"
	@printf '%s\n' "hooks-install: core.hooksPath=$$(git config --get core.hooksPath) — $(HOOKS_DIR)/commit-msg laeuft ab dem naechsten Commit (Umgehung: git commit --no-verify)."

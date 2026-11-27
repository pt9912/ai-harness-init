package emit

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// EnvironmentCheckShPath ist der Ort des Tool-/Versions-Checks im Ziel. Das
// Skript schreibt die Enforce-Emission (Klassentabelle in enforce.go). Konvergent —
// jeder Lauf schreibt ihn kanonisch neu (der Adopter passt die Inventar-Zeilen in
// tools/harness/environment-inventory.txt an, nicht das Skript).
const EnvironmentCheckShPath = "tools/harness/environment-check.sh"

// EnvironmentInventoryPath ist der Ort des Umgebungs-Inventars im Ziel. Konvergent —
// der Bootstrap schreibt den Basissatz bei jedem Lauf neu und haengt die Sprach-Zeilen
// an (dedupliert je Werkzeugname, geaendertes Soll gewinnt).
const EnvironmentInventoryPath = "tools/harness/environment-inventory.txt"

// EnvironmentMkPath ist der Ort des Tool-/Versions-Check-Fragments. Konvergent.
const EnvironmentMkPath = "harness/mk/environment.mk"

// environmentMk ist der Inhalt des Tool-/Versions-Check-Fragments. Die Praeferenz-
// Form in GATE_CHECKS stellt environment-check vor alle bereits akkumulierten Checks
// und — weil spaeter eingebundene Fragmente ihre Checks nur hinten anhaengen — vor
// ALLE Checks der Kante: ein Umgebungs-Befund endet dem Gate-Lauf, bevor ein Gate
// gegen fehlendes Werkzeug falsch faerbt (erster Check der Gates-Kante). Die Rezept-Zeile
// ist TAB-eingerueckt (Makefile-Pflicht).
const environmentMk = `# harness/mk/environment.mk — Tool-/Versions-Check-Fragment, emittiert von
# ai-harness-init. Erster Check der Gates-Kante: die Praeferenz-Zeile unten stellt
# environment-check vor alle Checks auf GATE_CHECKS, unabhaengig von der Alphabet-
# Ordnung dieses Fragments — spaeter eingebundene Fragmente haengen ihre Checks nur
# hinten an. Ein Umgebungs-Befund endet dem Lauf, bevor ein Gate gegen fehlendes
# Werkzeug falsch faerbt (erster Check der Gates-Kante).
#
# Grenze der Reihenfolge: die Zeile traegt die Prerequisite-Reihenfolge der
# Aggregator-Kette, keine Parallelitaets-Zusage — mit make -j laufen die Checks
# parallel; die Reihenfolge sagt, was zuerst anfaerbt, nicht dass der Lauf
# zeitlich am Umgebungs-Befund endet.
GATE_CHECKS := environment-check $(GATE_CHECKS)

.PHONY: environment-check

environment-check: ## Umgebungs-Befund je Werkzeug: Inventar-Soll am Host feststellen — IN gates (docker-los)
	@bash tools/harness/environment-check.sh
`

// inventoryBasissatz sind die Inventar-Zeilen jedes Ziels: die Werkzeuge, die die
// immer emittierten Gates (record-gates, baseline-verify, doc-gate) am Host brauchen.
// Pruefformen und Spaltenform sind die des Check-Skripts (SPEC-099); die d-check-
// Anwesenheit traegt die fetched Ablage (make dcheck-fetch) wie in der Lab-Fassung.
// Am Inventar ausdruecklich NICHT gemessen: awk — das Doc-Gate-Fragment misst die
// seine Probe selbst (DOC_GATE_ZIEL, lautem Abbruch, wenn awk fehlt); und die
// Werkzeuge des gepinnten Image-Wegs (opt-in) — dort adressiert der Digest, der Check
// vergleicht sie nicht.
var inventoryBasissatz = []string{
	"bash|Mindestversion|pflicht|manifest:4.0|Interpreter der Gate-Werkzeuge (tools/harness)|Die Gate-Skripte setzen die Bash-Sprachform 4.0 voraus; unterhalb endet der Check mit Diagnose statt Syntaxfehler — der Guard steht als erster Befehl des Skripts",
	"git|Faehigkeit|pflicht|manifest:probe:git-version|Gate-Nachweis und Stop-Hook (record-gates, working-tree-hash)|Probe: git --version traegt die Draht-Form ^git version — der Revisions-Zugriff ist Kontext des Laufs, nicht der Umgebung, und wird hier nicht gemessen",
	"make|Faehigkeit|pflicht|manifest:probe:make-gnu|Einziger Rezept-Lauefer (gates und die Fragmente)|Probe: make --version nennt GNU Make in der ersten Zeile — die Rezepte setzen GNU-make-Syntax voraus (include, lastword)",
	"sha256sum|Faehigkeit|pflicht|manifest:probe:sha256-abc|Baseline-Integritaet (baseline-verify) und der Traeger-Fetch|Probe: der sha256-Digest der Probe-Eingabe ABC traegt den festen Wert b5d4045c3f466fa91fe2cc6abe79232a1a57cdf104f7a26e716e0a1e2789df78 — die Pruefform misst Korrektheit, nicht die Distribution",
	"d-check|Anwesenheit|pflicht|manifest:anwesend|docs-check-host (Doku-Gate), docker-los|die Probe sieht den PATH UND die fetched Ablage .harness/state/bin/d-check (make dcheck-fetch, OCI-Pull nach dem DCHECK_DIGEST-Pin aus d-check.mk); die Version traegt keine Pin-Stelle — Anwesenheit; die Binaer-Beschaffung traegt der Fetch",
}

// EnsureInventoryRows fuegt die Zeilen eines Sprach-Skeletts in das liegende Inventar
// ein und schreibt es kanonisch neu: je Werkzeug-Namen die EINE Zeile — fehlt sie,
// kommt sie dazu; traegt sie ein anderes Soll, gewinnt die neu angebotene Zeile
// (konvergent, der letzte Lauf legt das Soll fest). Die Zeilen kommen aus
// gen.InventoryRows (Soll-Herkunft "abgeleitet:", Werte wie im Sprach-Fragment).
//
// Fehlt das Inventar, liegt kein Enforce-Lauf unter dem Ziel: die Gates-Kante existiert
// dort nicht und traegt kein Soll, das eine Sprach-Zeile benoetigen koennte (add-lang
// auf einem Verzeichnis ohne Bootstrap) — der Lauf traegt dann nichts nach. Der
// --lang-One-Shot reicht immer zuerst an Enforce, das Inventar steht darum in jedem
// gebootstrappten Ziel.
func EnsureInventoryRows(targetDir string, zeilen []string) (geaendert bool, err error) {
	if len(zeilen) == 0 {
		return false, nil
	}
	if _, err := os.Stat(filepath.Join(targetDir, filepath.FromSlash(EnvironmentInventoryPath))); os.IsNotExist(err) {
		return false, nil
	}
	for _, z := range zeilen {
		if !strings.Contains(z, "|") {
			return false, fmt.Errorf("Inventar-Zeile ohne Spalten-Form (|): %q", z)
		}
	}
	raw, err := os.ReadFile(filepath.Join(targetDir, filepath.FromSlash(EnvironmentInventoryPath)))
	if err != nil {
		return false, err
	}
	neu := string(raw)
	for _, z := range zeilen {
		name := strings.SplitN(z, "|", 2)[0]
		vorhanden := inventarZeileFuer(neu, name)
		switch {
		case vorhanden == "":
			if !strings.HasSuffix(neu, "\n") {
				neu += "\n"
			}
			neu += z + "\n"
			geaendert = true
		case vorhanden != z:
			neu = strings.Replace(neu, vorhanden+"\n", z+"\n", 1)
			geaendert = true
		}
	}
	if !geaendert {
		return false, nil
	}
	return true, writeFileMode(targetDir, EnvironmentInventoryPath, []byte(neu), 0o644)
}

// inventarZeileFuer liefert die erste Daten-Zeile zu einem Werkzeugnamen (je Name
// gewollt die eine), leer wenn keine steht.
func inventarZeileFuer(inventar, werkzeug string) string {
	for _, z := range strings.Split(inventar, "\n") {
		if z == "" || strings.HasPrefix(z, "#") {
			continue
		}
		if strings.SplitN(z, "|", 2)[0] == werkzeug {
			return z
		}
	}
	return ""
}

// EnvironmentMk liefert den Inhalt des Tool-/Versions-Check-Fragments (fuer
// Tests/Inspektion) — der netzlose Waechter auf die Praeferenz-Form, weil die
// "erster Check"-Zusage sonst erst an einem Lauf im gebootstrappten Ziel messbar
// waere.
func EnvironmentMk() string { return environmentMk }

// InventoryBasissatz liefert die Basis-Zeilen des Inventars (fuer Tests/Inspektion).
func InventoryBasissatz() []string { return inventoryBasissatz }

// EnvironmentCheck emittiert harness/mk/environment.mk nach targetDir; das Skript
// und der Inventar-Basissatz schreiben die Enforce-Emission (Klassentabelle in
// enforce.go). KONVERGENT (slice-038): das Fragment wird bei jedem Lauf kanonisch
// neu geschrieben.
func EnvironmentCheck(targetDir string) error {
	return writeFileMode(targetDir, EnvironmentMkPath, []byte(environmentMk), 0o644)
}

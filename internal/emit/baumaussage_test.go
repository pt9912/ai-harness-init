package emit_test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
	"github.com/pt9912/ai-harness-init/internal/fetch"
)

// TestInventurMessTag_IstDerGefetchteStand koppelt den Mess-Stand der Inventur an den
// Tag, den der Bootstrap holt. Ohne die Kopplung uebersteht ein Baseline-Sprung den
// Mess-Tag: die Tabelle traegt dann einen Stand, gegen den sie nicht gemessen ist, und
// der Adopter liest eine Bezugsangabe, die nicht gilt.
func TestInventurMessTag_IstDerGefetchteStand(t *testing.T) {
	t.Parallel()
	if emit.InventurMessTag != fetch.DefaultTag {
		t.Errorf("Mess-Stand der Inventur %q != gefetchter Baseline-Tag %q — die Zuordnung ist gegen einen anderen Baum gemessen, als das Ziel bekommt",
			emit.InventurMessTag, fetch.DefaultTag)
	}
}

// TestTraegerInventur_JedeZeileTraegtGenauEinenWert haelt die Form der Inventur: der
// Wert-Vorrat ist geschlossen, und keine Zelle bleibt leer. Eine leere Zelle waere die
// Abdeckungs-Luecke, die die Inventur schliesst — sie saehe aus wie "kein Traeger" und
// waere "nicht geprueft".
func TestTraegerInventur_JedeZeileTraegtGenauEinenWert(t *testing.T) {
	t.Parallel()
	erlaubt := map[emit.TraegerWert]bool{
		emit.TraegerKommtMit:      true,
		emit.TraegerLiegtBei:      true,
		emit.TraegerKommtNichtMit: true,
	}
	for _, e := range emit.TraegerInventur() {
		name := e.Modul + " " + e.Abschnitt
		if !erlaubt[e.Wert] {
			t.Errorf("%s: Wert %q liegt ausserhalb des geschlossenen Vorrats", name, e.Wert)
		}
		if strings.TrimSpace(e.Text) == "" {
			t.Errorf("%s: leere Zelle — der Wert nennt keinen Traeger und keinen Grund", name)
		}
		if e.Wert == emit.TraegerKommtNichtMit && e.Abwesend == "" {
			t.Errorf("%s: Abwesenheits-Aussage ohne Adresse — sie kann unter keiner Mutation rot werden", name)
		}
		if e.Wert != emit.TraegerKommtNichtMit && e.Abwesend != "" {
			t.Errorf("%s: Adresse an einem Wert, der keine Abwesenheit behauptet (%q)", name, e.Wert)
		}
	}
}

// TestTraegerInventur_KeineZelleBehauptetEineAbwesenheitDieDerEmitWiderlegt ist die
// eine Richtung, die DoD (3) schliesst: eine Zelle sagt "kommt nicht mit", waehrend
// derselbe Lauf unter ihrer Adresse etwas ablegt.
//
// Geprueft wird das PRAEFIX SAMT BESTAND, nicht ein geratener Dateiname: waechst der
// Bestand unter einem Praefix, an dem eine Zelle Abwesenheit behauptet, faellt dieser
// Test und zwingt einen Blick auf die Inventur. Ein geratener Name faellt nie.
func TestTraegerInventur_KeineZelleBehauptetEineAbwesenheitDieDerEmitWiderlegt(t *testing.T) {
	t.Parallel()
	// Der gepinnte Bestand je Praefix, an dem eine Zelle Abwesenheit behauptet.
	gepinnt := map[string][]string{
		"tools/harness/": {
			"tools/harness/baseline-verify.sh",
			"tools/harness/commit-msg-traceability.sh",
			"tools/harness/extract-command.awk",
			"tools/harness/history-range-guard.sh",
			"tools/harness/record-gates.sh",
			"tools/harness/selbstpruefung.sh",
			"tools/harness/slice-mv.sh",
			"tools/harness/working-tree-hash.sh",
		},
		"harness/mk/": {
			"harness/mk/archivierung.mk",
			"harness/mk/baseline.mk",
			"harness/mk/doc-gate.mk",
			"harness/mk/enforce.mk",
			"harness/mk/erfassung.mk",
			"harness/mk/hooks-install.mk",
			"harness/mk/selbstpruefung.mk",
			"harness/mk/slice-mv.mk",
		},
	}
	benutzt := map[string]bool{}
	for _, e := range emit.TraegerInventur() {
		if e.Wert != emit.TraegerKommtNichtMit {
			continue
		}
		soll, ok := gepinnt[e.Abwesend]
		if !ok {
			t.Fatalf("%s: die Adresse %q hat keinen gepinnten Bestand — ohne ihn prueft die Zelle nichts", e.Modul, e.Abwesend)
		}
		benutzt[e.Abwesend] = true
		ist := emit.PfadBestand(e.Abwesend)
		if strings.Join(ist, "\n") != strings.Join(soll, "\n") {
			t.Errorf("%s: der Bestand unter %q hat sich bewegt — die Zelle behauptet weiter Abwesenheit.\nist:  %v\nsoll: %v",
				e.Modul, e.Abwesend, ist, soll)
		}
	}
	for praefix := range gepinnt {
		if !benutzt[praefix] {
			t.Errorf("gepinnter Bestand fuer %q, aber keine Zelle behauptet dort Abwesenheit — der Pin haelt nichts", praefix)
		}
	}
}

// TestTraegerInventur_JedeGenannteAdresseEntstehtImZiel ist die POSITIVE Richtung: eine
// Zelle, die einen Träger nennt, nennt eine Adresse, die im Ziel wirklich entsteht.
//
// Ohne ihn ist die Zusage breiter als ihr Waechter: hermetisch geprueft waeren nur die
// Abwesenheits-Richtung und der Nenner, und eine Zelle duerfte auf einen Pfad zeigen, den
// kein Lauf schreibt — der Wert bliebe richtig, die Adresse falsch, und der Leser suchte
// an einer Stelle, an der nichts liegt.
//
// Die bekannte Menge ist die des Emitters selbst — Singletons aus dem Vorlagen-Satz
// (inklusive Struktur-.gitkeeps und Register-README) plus jede Adresse, die ein Lauf
// schreiben kann. Eine Adresse mit abschliessendem Trenner ist ein Verzeichnis und gilt
// als aufgeloest, sobald mindestens ein Pfad darunter liegt.
func TestTraegerInventur_JedeGenannteAdresseEntstehtImZiel(t *testing.T) {
	t.Parallel()
	singletons, err := emit.TemplateTargets(courseSet(), "Probe")
	if err != nil {
		t.Fatalf("TemplateTargets: %v", err)
	}
	bekannt := append(singletons, emit.EmittierteAdressen()...)
	if len(bekannt) == 0 {
		t.Fatal("leere Adress-Menge — der Test pruefte ueber nichts")
	}
	geprueft := 0
	for _, e := range emit.TraegerInventur() {
		if e.Wert == emit.TraegerKommtNichtMit {
			continue // Abwesenheit haelt die Gegenrichtung (PfadBestand)
		}
		for _, adresse := range emit.AdressenAusText(e.Text) {
			geprueft++
			treffer := false
			for _, p := range bekannt {
				if p == adresse || (strings.HasSuffix(adresse, "/") && strings.HasPrefix(p, adresse)) {
					treffer = true
					break
				}
			}
			if !treffer {
				t.Errorf("%s %s: die Zelle nennt %q — kein Lauf schreibt diese Adresse", e.Modul, e.Abschnitt, adresse)
			}
		}
	}
	if geprueft == 0 {
		t.Error("keine Adresse geprueft — die Erkennung trifft nichts, der Waechter ist leer")
	}
}

// TestTraegerInventur_ModulListeOhneWiederholung haelt die Nenner-Seite der Inventur
// hermetisch: die Modul-Liste ist die Menge, die test/baum-inventur.bats gegen das
// regelwerk/-Verzeichnis des gepinnten Baums haelt (der liegt unter .harness/ und damit
// ausserhalb des Docker-Build-Kontexts dieser Stufe).
func TestTraegerInventur_ModulListeOhneWiederholung(t *testing.T) {
	t.Parallel()
	module := emit.TraegerInventurModule()
	gesehen := map[string]bool{}
	for _, m := range module {
		if gesehen[m] {
			t.Errorf("Modul %q steht doppelt in der abgeleiteten Liste", m)
		}
		gesehen[m] = true
		if !strings.HasSuffix(m, ".md") {
			t.Errorf("Modul %q ist kein Dateiname des regelwerk/-Verzeichnisses", m)
		}
	}
	for _, e := range emit.TraegerInventur() {
		if !gesehen[e.Modul] {
			t.Errorf("Eintrag %q fehlt in der abgeleiteten Modul-Liste", e.Modul)
		}
	}
}

// TestBaumAussage_ImEmittiertenSatz ist die Verdrahtungs-Haelfte: die drei Aussagen
// stehen in der emittierten harness/conventions.md, vor dem Adaptions-Block, und die
// Inventur traegt eine Tabellenzeile je Eintrag.
func TestBaumAussage_ImEmittiertenSatz(t *testing.T) {
	t.Parallel()
	dir := t.TempDir()
	if err := emit.Templates(courseSet(), dir, "Probe"); err != nil {
		t.Fatalf("Templates: %v", err)
	}
	raw, err := os.ReadFile(filepath.Join(dir, "harness", "conventions.md"))
	if err != nil {
		t.Fatalf("emittierte conventions.md lesen: %v", err)
	}
	s := string(raw)
	for _, marke := range emit.BaumAussageMarken() {
		if !strings.Contains(s, marke) {
			t.Errorf("die emittierte harness/conventions.md traegt die Marke %q nicht", marke)
		}
	}
	block := strings.Index(s, emit.BaumAussageMarken()[0])
	anker := strings.Index(s, "\n## Adaptions-Block\n")
	if block < 0 || anker < 0 || block > anker {
		t.Errorf("der Block steht nicht vor dem Adaptions-Block (block=%d anker=%d)", block, anker)
	}
	for _, e := range emit.TraegerInventur() {
		zeile := "| `" + e.Modul + "`"
		if e.Abschnitt != "" {
			zeile += " " + e.Abschnitt
		}
		zeile += " | " + string(e.Wert) + " |"
		if !strings.Contains(s, zeile) {
			t.Errorf("Inventur-Zeile fehlt im emittierten Satz: %s", zeile)
		}
	}
	if strings.Contains(s, "<make-target>") {
		t.Error("der emittierte Block traegt einen neutralisierten Platzhalter — er nennt ein Ziel, das die Init-Phase nicht schreibt")
	}
}

// TestInjectBaumAussage_OhneAnkerFaelltLaut haelt die fail-closed-Richtung: verliert der
// Vorlagen-Satz die Ueberschrift, unter der der Block sitzt, bricht der Bootstrap — statt
// ein Ziel auszuliefern, das ueber seinen eigenen mitgelieferten Baum schweigt.
func TestInjectBaumAussage_OhneAnkerFaelltLaut(t *testing.T) {
	t.Parallel()
	targets, err := emit.InitInvariantTargets()
	if err != nil {
		t.Fatalf("InitInvariantTargets: %v", err)
	}
	if _, err := emit.InjectBaumAussage("# Harness-Konventionen\n\n## Baseline\n\nInhalt.\n", targets); err == nil {
		t.Error("ohne Anker kein Fehler — der Block faellt still weg")
	}
	out, err := emit.InjectBaumAussage("# K\n\n## Baseline\n\nInhalt.\n\n## Adaptions-Block\n\nIndex.\n", targets)
	if err != nil {
		t.Fatalf("mit Anker: %v", err)
	}
	if !strings.Contains(out, emit.BaumAussageMarken()[0]) {
		t.Error("mit Anker fehlt der Block")
	}
}

// TestBaumAussage_AnspruchAufEinFremdesZielFaelltLaut haelt die zweite fail-closed-
// Richtung: der Block geht durch dieselbe Neutralisierung wie jedes emittierte Dokument.
// Nennt er ein `make`-Ziel, das die Init-Phase nicht schreibt, bricht der Emit, statt
// einen Platzhalter auszuliefern.
func TestBaumAussage_AnspruchAufEinFremdesZielFaelltLaut(t *testing.T) {
	t.Parallel()
	if _, err := emit.InjectBaumAussage("# K\n\n## Adaptions-Block\n\nIndex.\n", []string{"gates"}); err == nil {
		t.Error("eine Ziel-Menge ohne die im Block genannten Ziele faerbt nicht rot")
	}
}

package emit_test

import (
	"bytes"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
	"github.com/pt9912/ai-harness-init/internal/gen"
	"github.com/pt9912/ai-harness-init/internal/span"
)

// Die Ziele des Aufraeum- und Berichts-Fragments. Sie stehen hier als Namen, weil sie
// der Gegenstand der Waechter sind: gemessen wird, WO sie auftauchen, nicht ob es sie
// gibt.
const (
	zielBericht = "span-report"
	zielClean   = "span-clean"
)

// wachstumsSatz ist die NICHT-Zusage neben dem Aufraeum-Kommando (LH-FA-10
// §Aufbewahrung: "ohne dessen Aufruf waechst der Bestand unbegrenzt, und das Repo sagt
// es"). EIN Satz, EINE Zusage: was daneben im Fragment ueber die fehlende Rotation
// steht, begruendet ihn und wird hier nicht mitbehauptet.
const wachstumsSatz = "OHNE DIESEN AUFRUF WAECHST DER BESTAND UNBEGRENZT."

// erfassungsFragment faehrt einen echten Emit in ein frisches Verzeichnis und liefert den
// Inhalt des abgelegten Fragments. GELESEN wird von der Platte: die Zusage gilt der Datei
// im Ziel, nicht dem Rueckgabewert einer Funktion.
func erfassungsFragment(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	if err := emit.Enforce(dir, io.Discard); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	return mustReadString(t, filepath.Join(dir, filepath.FromSlash(emit.ErfassungMkPath)))
}

// regelnIn liest aus einer Make-Quelle die Regeln (Ziel -> Prerequisites) und die an
// GATE_CHECKS gehaengten Ziele — Zeile fuer Zeile und unabhaengig von der Emit-Seite,
// aus demselben Grund wie claimsIn/rulesIn: eine gemeinsame Erfassung waere in beiden
// Richtungen gleich blind.
//
// Der Hilfetext hinter `##` ist KEINE Prerequisite: `gates: record-gates ## Alle Gates`
// nennt ein Ziel und danach Prosa.
func regelnIn(text string) (map[string][]string, []string) {
	regeln := map[string][]string{}
	var checks []string
	for _, line := range strings.Split(text, "\n") {
		if rest, ok := strings.CutPrefix(line, "GATE_CHECKS"); ok {
			if add, isAdd := strings.CutPrefix(strings.TrimLeft(rest, " \t"), "+="); isAdd {
				checks = append(checks, strings.Fields(add)...)
			}
			continue
		}
		// Rezept-Zeilen (TAB), .PHONY, Kommentare und Variablen beginnen nicht mit
		// einem Kleinbuchstaben.
		if line == "" || line[0] < 'a' || line[0] > 'z' {
			continue
		}
		name, rest, ok := strings.Cut(line, ":")
		if !ok || strings.HasPrefix(rest, "=") {
			continue // `x := …` ist keine Regel
		}
		if strings.TrimRight(name, "abcdefghijklmnopqrstuvwxyz0123456789-") != "" {
			continue
		}
		if i := strings.Index(rest, "##"); i >= 0 {
			rest = rest[:i]
		}
		regeln[name] = append(regeln[name], strings.Fields(rest)...)
	}
	return regeln, checks
}

// makeQuellenDesZiels liefert JEDE Make-Quelle, die im Ziel landet, je Ziel-Relpfad: die
// init-invarianten Fragmente samt Root-Aggregator (emit.InitFragments) und die
// Code-Gate-Fragmente jeder von gen getragenen Sprache.
//
// GELESEN, NICHT AUFGEZAEHLT — der Grund steht in slice-099 §6: ein Waechter ueber
// "erscheint nicht in dieser Kette" muss die Kette DES ZIELS lesen. Eine Liste hier
// bliebe gruen, sobald ein neues Fragment dazukommt.
//
// GRENZE: `d-check.mk` entsteht erst zur Bootstrap-Zeit (`d-check --print-mk`) und
// fehlt; aus ihm traegt die Menge allein die GATE_CHECKS-Kante des Doc-Gate-Fragments.
// Der reale Lauf ueber dem gebootstrappten Ziel steht in harness/tools/full-smoke.sh.
func makeQuellenDesZiels(t *testing.T) map[string]string {
	t.Helper()
	quellen, err := emit.InitFragments()
	if err != nil {
		t.Fatalf("InitFragments: %v", err)
	}
	for _, lang := range gen.SupportedLangs() {
		frag, fragErr := gen.CodeGateFragment(lang, ".", gen.DefaultVersion(lang))
		if fragErr != nil {
			t.Fatalf("CodeGateFragment(%s): %v", lang, fragErr)
		}
		quellen["harness/mk/"+lang+".mk"] = frag
	}
	if len(quellen) < 4 {
		t.Fatalf("nur %d Make-Quellen gelesen — der Waechter misst eine leere Kette", len(quellen))
	}
	return quellen
}

// hookPfadDesZiels liefert JEDE Datei des Hook-Pfads eines gebootstrappten Ziels je
// Ziel-Relpfad: die Hook-Konfiguration und jedes Hook-Skript. BEIDE Zweige aus ADR-0022
// Festlegung 5 sind drin — mit abgelegtem Traeger (dann traegt die Konfiguration den
// Erfassungs-Block) und ohne (dann nicht). Ein Waechter ueber nur einem Zweig liesse den
// anderen ungemessen.
func hookPfadDesZiels(t *testing.T) map[string]string {
	t.Helper()
	out := map[string]string{}
	sammle := func(dir, zweig string) {
		hooks := filepath.Join(dir, filepath.FromSlash(".claude/hooks"))
		eintraege, err := os.ReadDir(hooks)
		if err != nil {
			t.Fatalf("%s lesen: %v", hooks, err)
		}
		for _, e := range eintraege {
			out[zweig+" .claude/hooks/"+e.Name()] = mustReadString(t, filepath.Join(hooks, e.Name()))
		}
		out[zweig+" .claude/settings.json"] = mustReadString(t,
			filepath.Join(dir, filepath.FromSlash(".claude/settings.json")))
	}

	mitTraeger := t.TempDir()
	var notice bytes.Buffer
	if err := emit.Enforce(mitTraeger, &notice); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	if notice.Len() != 0 {
		t.Fatalf("die Traeger-Ablage scheiterte in dieser Umgebung — der Gelingens-Zweig ist hier nicht messbar: %s", notice.String())
	}
	sammle(mitTraeger, "mit Traeger:")

	sammle(zielOhneTraeger(t), "ohne Traeger:")
	return out
}

// zielOhneTraeger emittiert in ein Ziel, in dem die Traeger-Ablage SCHEITERT, und liefert
// dessen Verzeichnis. Das Scheitern wird HERGESTELLT, nicht abgewartet: eine Datei liegt
// dort, wo der Ablageort ein Verzeichnis braucht — derselbe Aufbau wie in
// TestEnforce_KeineErfassungOhneTraeger.
func zielOhneTraeger(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	blocker := filepath.Join(dir, filepath.FromSlash(".harness/state/bin"))
	if err := os.MkdirAll(filepath.Dir(blocker), 0o755); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	if err := os.WriteFile(blocker, []byte("kein Verzeichnis\n"), 0o644); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	var stumm bytes.Buffer
	if err := emit.Enforce(dir, &stumm); err != nil {
		t.Fatalf("der Bootstrap muss ohne Erfassung ERFOLGREICH enden, bekam: %v", err)
	}
	if stumm.Len() == 0 {
		t.Fatalf("der Fehlerzweig wurde nicht genommen — der Waechter misst dann den falschen Zweig")
	}
	return dir
}

// TestErfassungFragment_LiegtAuchOhneTraeger misst die Zusage, die erfassung.go ueber
// sich selbst macht: das Fragment ist UNBEDINGT und teilt den Zweig des Traegers nicht.
//
// Es ist die Gegenrichtung zu TestFeldliste_KeineFeldlisteOhneTraeger, und sie hat einen
// eigenen Grund: die Feldliste ist eine AUSSAGE ueber eine Erfassung und waere ohne
// Traeger eine Aussage ueber ein fehlendes Programm; das Fragment ist ein KOMMANDO, das
// die Abwesenheit selbst meldet. `span-clean` braucht den Traeger ohnehin nicht — ein
// Bestand aus einem frueheren Lauf ueberlebt ihn, und ohne Kommando bliebe der Adopter
// mit ihm allein.
//
// Rot-Gegenbeispiel: test/mutations/183-aufraeumkommando-am-traeger-zweig.sh.
func TestErfassungFragment_LiegtAuchOhneTraeger(t *testing.T) {
	dir := zielOhneTraeger(t)
	doc := filepath.Join(dir, filepath.FromSlash(emit.ErfassungMkPath))
	if _, err := os.Stat(doc); err != nil {
		t.Fatalf("ohne abgelegten Traeger fehlt %s — das Ziel haette kein Aufraeum-Kommando fuer einen Bestand, den ein frueherer Lauf hinterlassen hat: %v",
			emit.ErfassungMkPath, err)
	}
	if !strings.Contains(mustReadString(t, doc), zielClean) {
		t.Errorf("%s liegt ohne Traeger, nennt aber %q nicht", emit.ErfassungMkPath, zielClean)
	}
}

// makeRezeptPraefixe sind die Zeichen, die GNU make am Anfang einer Rezept-Zeile SELBST
// verarbeitet und der Shell NICHT weiterreicht: `@` (still), `-` (Fehler ignorieren),
// `+` (auch im Trockenlauf). Sie stehen in beliebiger Reihenfolge, duerfen sich
// wiederholen und duerfen von Leerraum durchsetzt sein — gemessen an GNU Make 4.3 mit
// einer Wegwerf-Makefile: `-@+ echo …` und `@ - echo …` laufen beide still.
//
// WARUM DAS HIER STEHT: wer eine Rezept-Zeile zerlegt, ohne sie abzuraeumen, liest `@rm`
// statt `rm`. Ein Waechter, der auf `rm` vergleicht, kann dann NIE ansprechen — er ist
// toter Code in einem gruenen Gate (Review-Befund slice-099 F-1).
const makeRezeptPraefixe = "@-+ \t"

// trennerSplit zerlegt eine Kommandozeile an den Shell-Trennern `;`, `&&`, `||`, `|`
// und `&`. Anfuehrungszeichen werden NICHT geachtet: ein Trenner in einem Zitat spaltet
// mit und erzeugt ein Segment, dessen Kommando-Wort niemand erwartet — der Waechter
// faellt dann laut, statt still durchzulassen (MR-017).
func trennerSplit(s string) []string {
	var out []string
	start := 0
	for i := 0; i < len(s); i++ {
		n := 0
		switch {
		case strings.HasPrefix(s[i:], "&&"), strings.HasPrefix(s[i:], "||"):
			n = 2
		case s[i] == ';' || s[i] == '|' || s[i] == '&':
			n = 1
		}
		if n == 0 {
			continue
		}
		out = append(out, s[start:i])
		i += n - 1
		start = i + 1
	}
	return append(out, s[start:])
}

// rezeptSegmente liefert die einzelnen Shell-Kommandos der Rezepte eines Make-Fragments:
// nur TAB-eingerueckte Zeilen, ohne die Rezept-Praefixe, ohne die
// Fortsetzungs-Backslashes, an den Shell-Trennern zerlegt.
func rezeptSegmente(frag string) []string {
	var out []string
	for _, line := range strings.Split(frag, "\n") {
		if !strings.HasPrefix(line, "\t") {
			continue // Regel-Kopf, Kommentar, Variable — kein Rezept
		}
		rumpf := strings.TrimSuffix(strings.TrimSpace(strings.TrimLeft(line, makeRezeptPraefixe)), "\\")
		for _, seg := range trennerSplit(rumpf) {
			if seg = strings.TrimSpace(seg); seg != "" {
				out = append(out, seg)
			}
		}
	}
	return out
}

// kommandoWort liefert das Kommando eines Segments. Shell-Schluesselwoerter davor
// werden weggelesen — `then exec …` fuehrt `exec` aus, nicht `then`. Ein Segment, das
// mit `for`/`case`/`select` beginnt, fuehrt eine WORTLISTE und kein Kommando; dafuer ist
// die Antwort leer.
func kommandoWort(seg string) string {
	felder := strings.Fields(seg)
	for len(felder) > 0 {
		switch felder[0] {
		case "for", "case", "select":
			return ""
		case "if", "elif", "then", "else", "fi", "do", "done", "while", "until", "esac", "!", "{", "}":
			felder = felder[1:]
		default:
			return felder[0]
		}
	}
	return ""
}

// TestErfassungFragment_ZielUndNichtZusage haelt DoD (2) von slice-099 fest, erste
// Haelfte: das Aufraeum-Kommando liegt im Ziel, es entfernt GENAU den Span-Bestand, und
// daneben steht geschrieben, dass der Bestand ohne seinen Aufruf unbegrenzt waechst
// (LH-FA-10 §Aufbewahrung, ADR-0022 Festlegung 6 Stueck 2).
//
// Der Ablageort steht NICHT als abgeschriebener Pfad im Waechter: er wird gegen span.Dir
// gehalten, denselben Ort, an den der Schreiber anhaengt. Driften die zwei, raeumt das
// Kommando ein Verzeichnis weg, in dem nichts liegt, und der Bestand waechst weiter —
// still, bei gruenem Kommando.
//
// Rot-Gegenbeispiele: test/mutations/177-aufraeumkommando-ohne-nicht-zusage.sh (der Satz
// faellt) · test/mutations/178-aufraeumkommando-bestand-drift.sh (der Ort driftet) ·
// test/mutations/184-aufraeumkommando-raeumt-mehr.sh (ein zweiter Pfad am `rm`) ·
// test/mutations/185-aufraeumkommando-fremdes-kommando.sh (ein Rezept-Kommando mehr).
func TestErfassungFragment_ZielUndNichtZusage(t *testing.T) {
	frag := erfassungsFragment(t)

	regeln, checks := regelnIn(frag)
	for _, ziel := range []string{zielBericht, zielClean} {
		if _, da := regeln[ziel]; !da {
			t.Errorf("%s definiert das Ziel %q nicht — das Ziel-Repo haette kein Kommando:\n%s", emit.ErfassungMkPath, ziel, frag)
		}
	}
	if len(checks) != 0 {
		t.Errorf("%s haengt %v an GATE_CHECKS — es traegt Kommandos, keine Gates", emit.ErfassungMkPath, checks)
	}

	// Leerraum-normalisiert verglichen: WO das Fragment umbricht, ist gleichgueltig;
	// WAS es sagt, nicht.
	flach := strings.Join(strings.Fields(frag), " ")
	if !strings.Contains(flach, wachstumsSatz) {
		t.Errorf("%s sagt die Nicht-Zusage nicht — es fehlt: %q", emit.ErfassungMkPath, wachstumsSatz)
	}

	// Der Ablageort ist der des Schreibers, nicht ein danebengelegter Pfad.
	if !strings.Contains(frag, "SPAN_DIR ?= "+span.Dir+"\n") {
		t.Errorf("%s nennt als Bestand nicht %q — Schreiber und Aufraeum-Kommando meinen dann verschiedene Orte:\n%s",
			emit.ErfassungMkPath, span.Dir, frag)
	}

	// ENG GEFASST — und die Grenze wird als VOLLSTAENDIGER Ist-Bestand gemessen, nicht
	// als Filter auf `rm`: die Rezepte fuehren genau die Kommandos, die hier stehen.
	//
	// Warum nicht "jedes Entfern-Kommando pruefen": das waere eine Aufzaehlung und damit
	// eine Untergrenze — `rmdir`, `shred`, `find … -delete` liefen still durch. Die
	// Gegenrichtung ist entscheidbar, weil dieses Fragment tool-eigen und klein ist: ein
	// Kommando, das hier fehlt, faellt laut auf, und wer eines ergaenzt, entscheidet
	// bewusst mit (MR-017: laut falsch schlaegt leise falsch).
	wollen := map[string]bool{"[": true, "exec": true, "echo": true, "rm": true}
	haben := map[string]bool{}
	var entfernt []string
	for _, seg := range rezeptSegmente(frag) {
		wort := kommandoWort(seg)
		if wort == "" {
			continue // Wortliste eines `for`, oder ein reines Schluesselwort
		}
		haben[wort] = true
		if wort == "rm" {
			entfernt = append(entfernt, seg)
		}
	}
	if len(haben) == 0 {
		t.Fatalf("aus %s liess sich kein einziges Rezept-Kommando lesen — der Waechter misst nichts:\n%s", emit.ErfassungMkPath, frag)
	}
	for wort := range haben {
		if !wollen[wort] {
			t.Errorf("%s fuehrt das Rezept-Kommando %q, das hier nicht erwartet ist — wer es ergaenzt, entscheidet ueber den Pruefbereich des Loeschpfads mit", emit.ErfassungMkPath, wort)
		}
	}
	for wort := range wollen {
		if !haben[wort] {
			t.Errorf("%s fuehrt das Rezept-Kommando %q nicht mehr — der Waechter prueft dann eine Menge, die es nicht gibt", emit.ErfassungMkPath, wort)
		}
	}

	// Und das eine Entfern-Kommando ist WOERTLICH der Span-Bestand — ueber die Variable,
	// deren Wert der Waechter oben an span.Dir bindet. Ein zweites Argument, ein zweites
	// `rm`, ein anderer Pfad: jedes davon ist unumkehrbar und trifft fremde Daten.
	if len(entfernt) != 1 || entfernt[0] != "rm -rf $(SPAN_DIR)" {
		t.Errorf("%s entfernt nicht genau den Span-Bestand — gelesen: %q, erwartet genau ein [rm -rf $(SPAN_DIR)]",
			emit.ErfassungMkPath, entfernt)
	}
}

// TestErfassungFragment_KeinAutomatischerAufrufer haelt DoD (2) fest, zweite Haelfte —
// und hier ist das Gegenbeispiel die AUTOMATIK, nicht das Fehlen: ein Loeschpfad, der von
// selbst laeuft, entfernt fremde Daten ohne Anlass und ist der teurere Fehlerfall
// (LH-FA-10 §Aufbewahrung).
//
// Gemessen wird ueber JEDE Make-Quelle des Ziels UND jede Datei seines Hook-Pfads: das
// Aufraeum-Ziel darf ausserhalb seines eigenen Fragments gar nicht vorkommen, und im
// Fragment selbst nur als Kommentar, als .PHONY-Nennung, als eigener Regel-Kopf oder im
// eigenen Rezept. Jede andere Stelle ist ein Aufrufer.
//
// Rot-Gegenbeispiel: test/mutations/179-aufraeumkommando-automatischer-aufrufer.sh.
func TestErfassungFragment_KeinAutomatischerAufrufer(t *testing.T) {
	quellen := makeQuellenDesZiels(t)
	for pfad, text := range hookPfadDesZiels(t) {
		quellen[pfad] = text
	}

	frag, da := quellen[emit.ErfassungMkPath]
	if !da || !strings.Contains(frag, zielClean) {
		t.Fatalf("%s fehlt in den gelesenen Quellen oder nennt %q nicht — der Waechter misst nichts",
			emit.ErfassungMkPath, zielClean)
	}

	for _, pfad := range sortierteSchluessel(quellen) {
		if pfad == emit.ErfassungMkPath {
			continue
		}
		if strings.Contains(quellen[pfad], zielClean) {
			t.Errorf("%s nennt %q — ausserhalb seines eigenen Fragments ist jede Nennung ein Aufrufer", pfad, zielClean)
		}
	}

	// Im Fragment: Zeile fuer Zeile, mit dem Ziel, zu dem sie gehoert.
	ziel := ""
	for _, line := range strings.Split(frag, "\n") {
		if !strings.HasPrefix(line, "\t") {
			ziel = ""
			if name, rest, ok := strings.Cut(line, ":"); ok && !strings.HasPrefix(rest, "=") &&
				strings.TrimRight(name, "abcdefghijklmnopqrstuvwxyz0123456789-") == "" && name != "" {
				ziel = name
			}
		}
		if !strings.Contains(line, zielClean) {
			continue
		}
		trimmed := strings.TrimSpace(line)
		erlaubt := strings.HasPrefix(trimmed, "#") ||
			strings.HasPrefix(trimmed, ".PHONY") ||
			ziel == zielClean
		if !erlaubt {
			t.Errorf("%s ruft %q automatisch: %q", emit.ErfassungMkPath, zielClean, trimmed)
		}
	}
}

// TestErfassung_NichtInDerGatesKette haelt DoD (3)(a) fest: kein emittiertes Gate haengt
// an Bericht oder Aufraeum-Kommando. Der Sensor misst ADRESSEN — die transitive
// Prerequisite-Huelle des emittierten `gates`-Ziels —, der Gegenstand ist die Aussage
// "das ist kein Sensor": eine Auswertung prueft nichts, und ein Gate ueber ihr waere
// eines ueber leerem Pruefbereich (LH-QA-01, ADR-0022 Festlegung 8).
//
// Rot-Gegenbeispiel: test/mutations/180-bericht-in-der-gates-kette.sh.
func TestErfassung_NichtInDerGatesKette(t *testing.T) {
	quellen := makeQuellenDesZiels(t)

	regeln := map[string][]string{}
	herkunft := map[string]string{}
	var checks []string
	for _, pfad := range sortierteSchluessel(quellen) {
		r, c := regelnIn(quellen[pfad])
		for k, v := range r {
			regeln[k] = append(regeln[k], v...)
			for _, p := range v {
				if _, schon := herkunft[p]; !schon {
					herkunft[p] = pfad
				}
			}
		}
		for _, name := range c {
			checks = append(checks, name)
			if _, schon := herkunft[name]; !schon {
				herkunft[name] = pfad
			}
		}
	}

	kette := map[string]bool{}
	offen := []string{"gates"}
	for len(offen) > 0 {
		aktuell := offen[0]
		offen = offen[1:]
		if kette[aktuell] {
			continue
		}
		kette[aktuell] = true
		for _, p := range regeln[aktuell] {
			if p == "$(GATE_CHECKS)" {
				offen = append(offen, checks...)
				continue
			}
			offen = append(offen, p)
		}
	}

	// Vorbedingung: die Huelle traegt wirklich die Gate-Kette. Ohne sie liefe der
	// Waechter ueber einem leeren Ergebnis und saehe nie etwas.
	for _, noetig := range []string{"record-gates", "baseline-verify", "docs-check"} {
		if !kette[noetig] {
			t.Fatalf("die gelesene gates-Kette traegt %q nicht — der Waechter misst nichts (gelesen: %v)", noetig, sortiert(kette))
		}
	}
	for _, ziel := range []string{zielBericht, zielClean} {
		if kette[ziel] {
			t.Errorf("%q haengt in der gates-Kette des Ziels (eingetragen in %s) — ein Gate ueber einem Bericht ist eines ueber leerem Pruefbereich",
				ziel, herkunft[ziel])
		}
	}
}

// TestErfassung_NichtImHookPfad haelt DoD (3)(b) fest: die Hook-Konfiguration des Ziels
// und seine Hook-Skripte nennen weder Bericht noch Aufraeum-Kommando. Ein Bericht im
// Hook-Pfad macht aus einem Leser einen Blockierer und bricht die fail-open-Klemme aus
// ADR-0011 Festlegung 6 — der Hook darf den Lauf, den er beobachtet, nicht aufhalten.
//
// Rot-Gegenbeispiel: test/mutations/181-bericht-im-hook-pfad.sh.
func TestErfassung_NichtImHookPfad(t *testing.T) {
	pfad := hookPfadDesZiels(t)

	// Vorbedingung: der Erfassungs-Zweig ist wirklich dabei — sonst laege der Waechter
	// ueber einem Hook-Pfad, in dem die Erfassung gar nicht vorkommt.
	var wrapper int
	for _, text := range pfad {
		if strings.Contains(text, "span-emit") {
			wrapper++
		}
	}
	if wrapper == 0 {
		t.Fatalf("kein Hook-Pfad-Eintrag nennt den Schreiber — der Waechter misst den falschen Bestand (gelesen: %v)", sortierteSchluessel(pfad))
	}

	for _, name := range sortierteSchluessel(pfad) {
		for _, ziel := range []string{zielBericht, zielClean} {
			if strings.Contains(pfad[name], ziel) {
				t.Errorf("%s nennt %q — im Hook-Pfad wird aus einem Leser ein Blockierer", name, ziel)
			}
		}
	}
}

// TestErfassung_KeinEintragInDenGateTabellen haelt DoD (3)(c) fest: keine Zeile einer
// emittierten Gate-Tabelle behauptet Bericht oder Aufraeum-Kommando als Sensor. Ein
// Eintrag dort BEHAUPTET einen Sensor — das Ziel fuehrt eine Zeile, die ausdruecklich
// KEIN Gate sagt, oder gar keine.
//
// Die Richtung ist neu geworden, nicht schon immer da: mit dem Fragment sind die zwei
// Ziele init-invariant, und emit.NeutralizeMakeClaims laesst eine Nennung darum stehen,
// die es vorher zu `<make-target>` gemacht haette. Genau diese Luecke misst der Waechter.
//
// GRENZE, benannt: gemessen wird der Emit ueber der Fixture courseSet(); ein Eintrag im
// REALEN vendored Vorlagen-Satz faellt hier nicht auf. Die Fixture haelt
// test/courseset-fixture.bats am realen Satz fest — nach DATEIBESTAND, nicht nach Inhalt.
//
// Rot-Gegenbeispiel: test/mutations/182-bericht-in-der-gate-tabelle.sh.
func TestErfassung_KeinEintragInDenGateTabellen(t *testing.T) {
	dir := emitDokumentSatz(t, claimSet(t))

	var zeilen int
	walkErr := filepath.WalkDir(dir, func(p string, d fs.DirEntry, err error) error {
		if err != nil || d.IsDir() || !strings.HasSuffix(p, ".md") {
			return err
		}
		rel, _ := filepath.Rel(dir, p)
		for _, line := range strings.Split(mustReadString(t, p), "\n") {
			if !strings.HasPrefix(strings.TrimSpace(line), "|") || !strings.Contains(line, "make ") {
				continue
			}
			zeilen++
			for _, ziel := range []string{zielBericht, zielClean} {
				if !strings.Contains(line, "make "+ziel) {
					continue
				}
				if !strings.Contains(line, "kein Gate") {
					t.Errorf("%s fuehrt %q in einer Gate-Tabelle, ohne KEIN GATE zu sagen: %q", rel, "make "+ziel, strings.TrimSpace(line))
				}
			}
		}
		return nil
	})
	if walkErr != nil {
		t.Fatalf("emittierten Satz lesen: %v", walkErr)
	}
	if zeilen == 0 {
		t.Fatalf("keine einzige Gate-Tabellen-Zeile erkannt — der Waechter misst nichts")
	}
}

// sortierteSchluessel liefert die Schluessel einer Datei-Map sortiert. Ohne sie haengt
// die Reihenfolge der Meldungen an der Map-Iteration, und zwei Laeufe ueber demselben
// Befund meldeten ihn verschieden.
func sortierteSchluessel(m map[string]string) []string {
	out := make([]string, 0, len(m))
	for k := range m {
		out = append(out, k)
	}
	sort.Strings(out)
	return out
}

// sortiert liefert die gesetzten Schluessel einer Menge sortiert — fuer die Meldung, die
// eine unvollstaendig gelesene Kette zeigt.
func sortiert(m map[string]bool) []string {
	out := make([]string, 0, len(m))
	for k, v := range m {
		if v {
			out = append(out, k)
		}
	}
	sort.Strings(out)
	return out
}

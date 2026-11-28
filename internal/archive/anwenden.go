package archive

import (
	"archive/zip"
	"bytes"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

// Git ist die Menge der git-Operationen, die der schreibende Lauf braucht. Sie
// steht als Schnittstelle, weil die zwei Eigenschaften, die an ihr haengen —
// die Zwei-Commit-Trennung und das explizite Staging — sonst nur an einem
// echten Repo pruefbar waeren. Der Aufrufer verdrahtet `git`, der Test einen
// Mitschreiber ueber einem synthetischen Baum. `Rm` fehlt seit ADR-0061 mit
// Bedacht: der Lauf loescht kein Zeitdokument mehr ersatzlos, jeder
// Review-Report ueberlebt als Stub an unveranderter Adresse.
type Git interface {
	Mv(alt, neu string) error
	Add(pfade []string) error
	Commit(nachricht string) error
}

// Umzug ist eine Datei, die der Lauf nach done/<wave-id>/ zieht — alter und
// neuer Pfad, repo-relativ und Forward-Slash-normalisiert wie in Markdown-Links.
type Umzug struct {
	Alt string
	Neu string
}

// Umzuege nennt die Dateien, die der Lauf bewegt: die eingesammelten Slices und
// den Welle-Plan. Die Review-Reports stehen NICHT darin — sie werden nicht
// bewegt; ihr Stub tritt an dieselbe Adresse (ADR-0061 Festlegung 1).
func Umzuege(b Bestand) []Umzug {
	ziel := doneDir + "/" + b.Welle
	var out []Umzug
	for _, p := range append(b.Slices(), b.Plaene...) {
		out = append(out, Umzug{Alt: p, Neu: ziel + "/" + filepath.Base(p)})
	}
	sort.Slice(out, func(i, j int) bool { return out[i].Alt < out[j].Alt })
	return out
}

// ZuStagen nennt die Pfade, die der Inhalts-Commit stagt: das Archiv, die Stubs
// der bewegten Dateien, die Report-Stubs an ihren UNVERAENDERTEN Adressen
// (geaenderte Dateien, kein geloeschter Pfad — ADR-0061 Festlegung 3), die
// Umzugs-Stubs an der ALTEN Adresse je referenziertem Umzug (ADR-0112
// Festlegung 1) und die Dateien, deren Verweise nachgezogen wurden — und sonst
// nichts.
//
// ZUSAGE, und sie ist ADR-0033 Abnahme-Kriterium 2 in seiner schreibenden
// Haelfte: die Liste ist AUFGEZAEHLT, nicht `-A`. Der Inhalts-Commit ist der
// Wave-Self-Close-Punkt, den ein Audit liest; traegt er fremden Inhalt, ist die
// Zusage "der Archivierungs-Commit bezeugt die Vollstaendigkeit" gebrochen,
// ohne dass etwas rot wird.
// Gedeckt von TestZuStagenNenntNurArchivStubsUndNachgezogene;
// test/mutations/241-archive-welle-go-staging-explizit.sh nimmt die Aufzaehlung weg.
func ZuStagen(b Bestand, umzugsStubs, nachgezogen []string) []string {
	ziel := doneDir + "/" + b.Welle
	menge := map[string]bool{ziel + "/" + archivName: true}
	for _, u := range Umzuege(b) {
		menge[u.Neu] = true
	}
	for _, r := range b.Reviews {
		menge[filepath.ToSlash(r)] = true
	}
	for _, s := range umzugsStubs {
		menge[filepath.ToSlash(s)] = true
	}
	for _, n := range nachgezogen {
		menge[filepath.ToSlash(n)] = true
	}
	out := make([]string, 0, len(menge))
	for p := range menge {
		out = append(out, p)
	}
	sort.Strings(out)
	return out
}

// Anwenden fuehrt die Archivierung aus: Move und Commit 1, das Zip, beide
// Stub-Arten aus den vendored Vorlagen, den Report-Stub aus der repo-eigenen
// Vorlage, der Verweis-Nachzug und Commit 2.
//
// ZWEI COMMITS, und die Trennung ist die von AGENTS.md 3.3: Commit 1 traegt den
// reinen Move und kein Byte Inhalt, Commit 2 traegt Archiv, Stubs und Nachzug.
// Faellt die Rename-Erkennung unter die Aehnlichkeits-Schwelle, ist die Herkunft
// der archivierten Datei aus dem Log nicht mehr ablesbar.
// Gedeckt von TestAnwendenTrenntMoveVonInhalt.
//
// KEIN ROLLBACK bei einem Fehler mittendrin — derselbe Umgang wie bei jedem
// git-mv-Schritt: der Bediener sieht den Zwischenstand per `git status`. Ein
// Fehler NACH Commit 1 traegt darum den Rueckweg im Text (NachCommit1Fehler).
//
// `dateien` ist der Suchraum-Eingang des Verweis-Nachzugs (git ls-files); `out`
// nimmt den Fortschrittstext.
func Anwenden(root string, b Bestand, dateien []string, g Git, out io.Writer) error {
	return anwenden(root, b, dateien, g, out, Zip)
}

// anwenden ist Anwenden mit dem Schreibpunkt des Archivs als Parameter; der Test
// legt darueber zwischen Schreiben und Rueckleseprobe ein defektes Zip (export_test.go).
func anwenden(root string, b Bestand, dateien []string, g Git, out io.Writer, schreibeZip zipSchreiber) error {
	altbestand := b.Welle == AltbestandSchluessel
	// ZUSAGE (ADR-0090 Festlegung 1 und 3): der Schluessel AltbestandSchluessel laeuft nur
	// mit einer nicht leeren Kennung des Aufrufers; ohne sie endet der Lauf hier — vor dem
	// Verzeichnis, vor dem ersten Mv und ohne Commit. Gedeckt von
	// TestAnwendenAltbestandOhneKennungBrichtVorDemMoveAb.
	if altbestand && b.Kennung == "" {
		return ErrKennungFehlt
	}
	if altbestand && len(altbestandFremdesPlanBild(b)) > 0 {
		return fmt.Errorf("der Schluessel %s hat keinen Welle-Plan, %d Datei(en) '%s*.md' in %s/",
			b.Welle, len(altbestandFremdesPlanBild(b)), b.Welle, doneDir)
	}
	if !altbestand && !b.EinPlanVorhanden() {
		return fmt.Errorf("genau ein Welle-Plan erwartet, %d vorhanden", len(b.Plaene))
	}
	vorlagen, err := VorlagenVerzeichnis(root)
	if err != nil {
		return err
	}
	ziel := doneDir + "/" + b.Welle
	if err := os.MkdirAll(filepath.Join(root, filepath.FromSlash(ziel)), 0o755); err != nil {
		return fmt.Errorf("%s anlegen: %w", ziel, err)
	}

	umzuege := Umzuege(b)
	for _, u := range umzuege {
		if err := g.Mv(u.Alt, u.Neu); err != nil {
			return err
		}
	}
	if err := g.Commit("archive-welle: " + b.Welle + "  Zeitdokumente nach " + ziel + "/ (reiner Move" + kennungSuffix(b) + ")"); err != nil {
		return err
	}

	// Ab hier traegt der Baum Commit 1. Jeder Fehler bekommt den Rueckweg mit.
	if err := inhaltsSchritt(root, b, dateien, vorlagen, umzuege, g, out, schreibeZip); err != nil {
		return NachCommit1Fehler{Welle: b.Welle, Ziel: ziel, Ursache: err}
	}
	return nil
}

// ErrKennungFehlt ist der Abbruch des Schluessels AltbestandSchluessel ohne
// Kennung des Aufrufers. Der Text nennt das Argument und keine Kennung: welche
// das Ziel annimmt, entscheidet dessen commit-msg-Traeger (ADR-0090 Festlegung 1);
// die Raender der Pflicht — nach den Sperren, nicht unter --vorschau, leer gilt als
// fehlend — setzt Festlegung 3.
var ErrKennungFehlt = errors.New("der Schluessel " + AltbestandSchluessel +
	" braucht eine Kennung des eigenen Repos (--kennung <K>, im Make-Ziel KENNUNG=<K>), " +
	"die beide Commits tragen und die der commit-msg-Traeger dieses Repos annimmt — nichts wurde bewegt")

// kennungSuffix haengt die Kennung des Aufrufers (Bestand.Kennung) an beide
// Commit-Nachrichten; ohne Kennung bleiben sie unveraendert. Das Werkzeug bringt
// keine eigene mit und prueft die gegebene nicht gegen die Traceability-Menge —
// Richter ist der commit-msg-Traeger des Repos (ADR-0090 Festlegung 1).
// Gedeckt von TestAnwendenTraegtDieKennungDesAufrufersInBeidenCommits.
func kennungSuffix(b Bestand) string {
	if b.Kennung == "" {
		return ""
	}
	return ", " + b.Kennung
}

// NachCommit1Fehler ist ein Fehler, der NACH dem Move-Commit auftrat. Der Baum
// traegt dann den Move, das Archiv und die Stubs; ein zweiter Aufruf scheitert an
// zwei eigenen Vorpruefungen zugleich ("Arbeitsbaum nicht sauber" UND "schon
// archiviert"). Der Rueckweg steht darum im Fehlertext, statt den Bediener in
// einem Zustand zu lassen, aus dem das Werkzeug selbst nicht herausfuehrt.
type NachCommit1Fehler struct {
	Welle   string
	Ziel    string
	Ursache error
}

func (e NachCommit1Fehler) Error() string {
	return fmt.Sprintf("Abbruch nach Commit 1 (reiner Move): %v\n"+
		"  Zurueck auf den Stand vor dem Lauf:\n"+
		"    git reset --hard HEAD~1 && git clean -fd -- %s", e.Ursache, e.Ziel)
}

func (e NachCommit1Fehler) Unwrap() error { return e.Ursache }

// inhaltsSchritt ist alles, was in Commit 2 landet: Zip, Stubs der bewegten
// Dateien, Report-Stubs an unveranderter Adresse, Verweis-Nachzug, Staging.
func inhaltsSchritt(root string, b Bestand, dateien []string, vorlagen string, umzuege []Umzug, g Git, out io.Writer, schreibeZip zipSchreiber) error {
	ziel := doneDir + "/" + b.Welle
	zipRel := ziel + "/" + archivName

	// Das Zip entsteht VOR den Stubs: an den neuen Pfaden liegt noch der
	// Volltext, den es aufnimmt.
	imArchiv := make([]string, 0, len(umzuege)+len(b.Reviews))
	for _, u := range umzuege {
		imArchiv = append(imArchiv, u.Neu)
	}
	imArchiv = append(imArchiv, b.Reviews...)
	if err := schreibeZip(root, zipRel, imArchiv); err != nil {
		return err
	}

	// ZUSAGE: das Archiv ist gelesen und byte-gleich zu seinen Quellen, BEVOR ein
	// Original zum Stub gekuerzt oder ein Review-Report geloescht wird. Bei einem
	// Befund endet der Lauf hier: kein Stub geschrieben, nichts geloescht, nichts
	// gestagt, kein Commit 2 — auf Platte bleibt das defekte Zip an seinem Pfad
	// liegen (der Rueckweg aus NachCommit1Fehler raeumt es). Die Zusage gilt fuer den
	// Zeitpunkt der Probe, nicht fuer die Haltbarkeit der Datei danach.
	// Gedeckt von TestAnwendenBrichtVorDemKuerzenAb;
	// test/mutations/771-archiv-rueckleseprobe-ausgehebelt.sh macht die Probe wirkungslos.
	if err := pruefeArchiv(root, zipRel, imArchiv); err != nil {
		return err
	}

	if err := schreibeStubs(root, b, vorlagen, umzuege, zipRel); err != nil {
		return err
	}

	if err := schreibeReportStubs(root, b, zipRel); err != nil {
		return err
	}

	// Der Umzugs-Stub-Write liegt VOR dem Nachziehen (ADR-0112 Festlegung 1): der
	// Stub tritt der Stub-Familie bei, die der Nachzug danach als Teil des Baums
	// liest — dieselbe Ordnung wie bei schreibeStubs/schreibeReportStubs. Er
	// verlaesst sich nicht auf den Nachzug: die Referenzen, die er traegt, stehen
	// in keinem Baum, den der Nachzug erreicht.
	umzugsStubs, err := schreibeUmzugStubs(root, b, umzuege, dateien)
	if err != nil {
		return err
	}

	nachgezogen, err := Nachziehen(root, dateien, b.Bewegte(), b.Welle)
	if err != nil {
		return err
	}
	beruehrt := make([]string, 0, len(nachgezogen))
	for _, f := range nachgezogen {
		beruehrt = append(beruehrt, f.Datei)
	}
	if err := g.Add(ZuStagen(b, umzugsStubs, beruehrt)); err != nil {
		return err
	}
	if err := g.Commit("archive-welle: " + b.Welle + "  Archiv, Stubs und Verweis-Nachzug (Inhalt, getrennt vom Move: git mv und Inhaltsaenderung in zwei Commits" + kennungSuffix(b) + ")"); err != nil {
		return err
	}

	groesse, _ := os.Stat(filepath.Join(root, filepath.FromSlash(zipRel)))
	fmt.Fprintf(out, "archive-welle ok: %s\n", b.Welle)
	if len(b.Plaene) > 0 {
		fmt.Fprintf(out, "  Commit 1 (reiner Move): %d Slice(s) + Welle-Plan nach %s/\n", len(b.Slices()), ziel)
	} else {
		fmt.Fprintf(out, "  Commit 1 (reiner Move): %d Slice(s) nach %s/\n", len(b.Slices()), ziel)
	}
	bytes := int64(0)
	if groesse != nil {
		bytes = groesse.Size()
	}
	fmt.Fprintf(out, "  Commit 2 (Inhalt): %s (%d Bytes), %d Stub(s) bewegter Dateien, %d Report-Stub(s), %d Umzugs-Stub(s)\n",
		archivName, bytes, len(umzuege), len(b.Reviews), len(umzugsStubs))
	// Dieselbe Zeile wie in der Vorschau, aus derselben Funktion: zwei Fassungen
	// derselben Ausgabe drifteten.
	schreibeVerweise(out, nachgezogen)
	fmt.Fprintln(out, "  Naechster Schritt: make docs-check — er zeigt, was der Nachzug nicht erreicht.")
	return nil
}

// schreibeStubs ersetzt jede bewegte Datei durch ihren Stub. Der Welle-Plan
// bekommt die Welle-Vorlage, jeder Slice die Slice-Vorlage. Die Review-Reports
// werden hier nicht angefasst — ihr Stub schreibt schreibeReportStubs.
func schreibeStubs(root string, b Bestand, vorlagen string, umzuege []Umzug, zipRel string) error {
	// Der Schluessel AltbestandSchluessel hat weder Plan noch Ergebnisnotiz: kein
	// Welle-Stub, und `Geschlossen:` traegt den Leerwert `—` (WelleDatum ohne Zeile).
	planBase, planNeu, wDatum := "", "", WelleDatum("")
	if len(b.Plaene) > 0 {
		planBase = filepath.Base(b.Plaene[0])
		planNeu = doneDir + "/" + b.Welle + "/" + planBase
		ergebnis, _, err := lies(root, b.Ergebnis)
		if err != nil {
			return err
		}
		wDatum = WelleDatum(ergebnis)
	}

	for _, u := range umzuege {
		inhalt, ok, err := lies(root, u.Neu)
		if err != nil {
			return err
		}
		if !ok {
			return fmt.Errorf("%s nach dem Move nicht lesbar", u.Neu)
		}
		var text string
		if u.Neu == planNeu {
			text, err = welleStub(vorlagen, b, wDatum, zipRel, u.Neu, inhalt)
		} else {
			text, err = sliceStub(root, vorlagen, b, planBase, wDatum, zipRel, u.Neu, inhalt)
		}
		if err != nil {
			return err
		}
		// ZUSAGE: der Schreibzugriff kommt NACH dem Form-Urteil. Ein form-widriger
		// Stub erreicht den Baum nicht, der Lauf bricht zwischen den zwei Commits
		// ab und nennt den Rueckweg. Gedeckt von
		// TestAnwendenBrichtBeiVerletzterStubFormAb;
		// test/mutations/243-archive-welle-go-stubform-verdrahtung.sh nimmt sie weg.
		if err := FormOK(text); err != nil {
			return fmt.Errorf("%s: %v", u.Neu, err)
		}
		if err := os.WriteFile(filepath.Join(root, filepath.FromSlash(u.Neu)), []byte(text), 0o644); err != nil {
			return fmt.Errorf("%s schreiben: %w", u.Neu, err)
		}
	}
	return nil
}

// sliceStub baut den Stub eines Slice. `Welle:` traegt die ZUGEHOERIGKEIT
// (Geschwister-Link auf den Welle-Plan, der in dasselbe Verzeichnis mitzieht,
// oder "ohne Welle"); `Archiviert mit:` traegt die einsammelnde Welle. Fuer einen
// wellenlosen Slice sind das zwei verschiedene Tatsachen.
func sliceStub(root, vorlagen string, b Bestand, planBase, wDatum, zipRel, neu, inhalt string) (string, error) {
	nummer := SliceNummer(filepath.Base(neu))
	welleFeld := "ohne Welle"
	if KlasseVon(WelleFeld(inhalt), b.Welle) == Mitglied {
		welleFeld = "[" + b.Welle + "](" + planBase + ")"
	}
	return AusVorlage(filepath.Join(vorlagen, stubVorlageSlice), []Ersetzung{
		{"<Kennung>", nummer},
		{"<Titel>", TitelVon(Kopfzeile(inhalt))},
		{"<wave-id | ohne Welle>", welleFeld},
		{"<JJJJ-MM-TT>", GeschlossenDatum(inhalt, wDatum)},
		{"<BEO-*, ADR-*, Folge-Slice — oder `— keine —`>", Hervorgegangen(root, inhalt, b.Welle)},
		{"done/<wave-id>/" + archivName, zipRel},
		{"<pfad-im-archiv>", neu},
		{"<wave-id>", b.Welle},
	})
}

// reportForm ist die Form-Pruefung des Report-Zweigs. Sie steht als eigene
// Funktion statt als direkter FormOK-Ruf am Ort, damit die Mutations-Anlage
// sie einzeln enthemmt: die Verdrahtung misst
// test/mutations/819-archive-welle-go-report-stub-form-verdrahtung.sh.
func reportForm(inhalt string) error { return FormOK(inhalt) }

// schreibeReportStubs ersetzt jeden Review-Report durch seinen Stub an
// UNVERAENDERTER Adresse (ADR-0061 Festlegung 1). Dieselbe Form-Verdrahtung wie
// ueber den Umzuegen: die Pruefung VOR dem Schreibzugriff, damit ein
// form-widriger Report-Stub den Baum nicht erreicht; der Lauf bricht zwischen
// den zwei Commits ab und nennt den Rueckweg. Der Report-Zweig ist eigen
// gedeckt (TestAnwendenBrichtBeiVerletzterReportStubFormAb,
// test/mutations/819); die Logik der Pruefung haelt
// TestFormOKMeldetStehengebliebeneUeberschrift.
func schreibeReportStubs(root string, b Bestand, zipRel string) error {
	for _, r := range b.Reviews {
		inhalt, ok, err := lies(root, r)
		if err != nil {
			return err
		}
		if !ok {
			return fmt.Errorf("%s vor dem Stub nicht lesbar", r)
		}
		text, err := reportStub(root, b.Welle, zipRel, r, inhalt)
		if err != nil {
			return err
		}
		if ferr := reportForm(text); ferr != nil {
			return fmt.Errorf("%s: %v", r, ferr)
		}
		if err := os.WriteFile(filepath.Join(root, filepath.FromSlash(r)), []byte(text), 0o644); err != nil {
			return fmt.Errorf("%s schreiben: %w", r, err)
		}
	}
	return nil
}

// umzugForm ist die Form-Pruefung des Umzugs-Stubs. Eigene Funktion statt
// direkter FormOKUmzug-Ruf am Ort, dieselbe Form wie reportForm: die
// Mutations-Anlage enthemmt sie einzeln
// (test/mutations/825-archive-welle-go-umzug-stub-form-verdrahtung.sh).
func umzugForm(inhalt string) error { return FormOKUmzug(inhalt) }

// schreibeUmzugStubs schreibt je REFERENZIERTEM Umzug einen Umzugs-Stub an der
// flachen Alt-Adresse done/<base> (ADR-0112 Festlegung 1). Das Kriterium ist das
// Suchraum-Differenzial: ein Basename aus b.Verschwindend(), der in einer Datei
// aus Suchraum(…)\SuchraumNachzug(…) steht — heute allein docs/plan/adr; entsteht
// ein vierter ausgenommener Baum, traegt SuchraumDifferenzial ihn ohne neue
// Entscheidung. Ohne solchen Verweis schreibt die Funktion nichts.
//
// DIE STUB-FAMILIE UND DER NACHZUG: der Write liegt im inhaltsSchritt VOR dem
// Nachziehen — der Nachzug liest den frisch geschriebenen Stub als Teil des
// Baums, wie er es mit den Stub der bewegten Slices und den Report-Stubs liest
// (TestUmzugsStubVorDemNachziehenGesehen haelt die Ordnung am Lauf).
//
// GRENZE: gefunden wird der BASENAME als Teilzeichenkette — dieselbe
// fail-closed-Form wie beim Haenger-Waechter (treffer); ein gleichlautender Name
// im Fliesstext loest ebenfalls einen Stub aus. Die Rueckgabe sind die
// geschriebenen Alt-Adressen (repo-relativ) — die ZUSAETZLICHEN Pfade der
// Staging-Aufzaehlung (ZuStagen).
func schreibeUmzugStubs(root string, b Bestand, umzuege []Umzug, dateien []string) ([]string, error) {
	ziele, err := referenzierteUmzuege(root, b, dateien)
	if err != nil {
		return nil, err
	}
	if len(ziele) == 0 {
		return nil, nil
	}
	neuNachAlt := make(map[string]Umzug, len(umzuege))
	for _, u := range umzuege {
		neuNachAlt[u.Alt] = u
	}
	var geschriebene []string
	for _, alt := range ziele {
		u, da := neuNachAlt[alt]
		if !da {
			return nil, fmt.Errorf("referenzierter Umzug %s ohne Umzug des Laufs", alt)
		}
		inhalt, ok, err := lies(root, u.Neu)
		if err != nil {
			return nil, err
		}
		if !ok {
			return nil, fmt.Errorf("%s nach dem Move nicht lesbar", u.Neu)
		}
		text, err := umzugStub(root, u, inhalt, b.Welle)
		if err != nil {
			return nil, err
		}
		// DIESELBE Verdrahtungs-Setzung wie ueber den Umzuegen und den Reports:
		// die Pruefung VOR dem Schreibzugriff, damit ein form-widriger
		// Umzugs-Stub den Baum nicht erreicht; der Lauf bricht zwischen den zwei
		// Commits ab und nennt den Rueckweg. Gedeckt von
		// TestAnwendenBrichtBeiVerletzterUmzugStubFormAb; 825 nimmt sie weg.
		if ferr := umzugForm(text); ferr != nil {
			return nil, fmt.Errorf("%s: %v", alt, ferr)
		}
		if err := os.WriteFile(filepath.Join(root, filepath.FromSlash(alt)), []byte(text), 0o644); err != nil {
			return nil, fmt.Errorf("%s schreiben: %w", alt, err)
		}
		geschriebene = append(geschriebene, alt)
	}
	return geschriebene, nil
}

// referenzierteUmzuege liefert die Alt-Pfade der Umzuege, deren Basename eine
// Datei des Suchraum-Differenzials referenziert — das Differenzial-Kriterium
// gesammelt (ADR-0112 Festlegung 1). Diese Funktion ist der gemeinsame Kern des
// Kriteriums: die Vorschau liest sie als Funde-Zeilen je verweisender Datei
// (UmzugsFunde), der schreibende Lauf als Stub-Menge.
func referenzierteUmzuege(root string, b Bestand, dateien []string) ([]string, error) {
	diff := SuchraumDifferenzial(dateien)
	if len(diff) == 0 {
		return nil, nil
	}
	verschwindend := b.Verschwindend()
	weg := make(map[string]bool, len(verschwindend))
	for _, v := range verschwindend {
		weg[filepath.ToSlash(v)] = true
	}
	ziele := make(map[string]bool)
	for _, datei := range diff {
		if weg[datei] {
			continue
		}
		inhalt, ok, err := lies(root, datei)
		if err != nil {
			return nil, err
		}
		if !ok {
			continue
		}
		for _, ziel := range zieleTrifft(inhalt, verschwindend) {
			ziele[ziel] = true
		}
	}
	alte := make([]string, 0, len(ziele))
	for z := range ziele {
		alte = append(alte, z)
	}
	sort.Strings(alte)
	return alte, nil
}

// umzugStub baut den Stub eines bewegten Zeitdokuments an seiner ALTEN Adresse.
// Die H1-Zeile kommt aus dem Volltext (die Identitaet ist die des Slices bzw.
// Welle-Plans), der Umzugs-Zeiger druckt die repo-relative NEUE Arbeitsbaum-
// Adresse ab (done/<wave-id>/… bzw. done/altbestand/…) und `Archiviert mit:`
// nennt den Lauf, der gezogen hat (ADR-0112 Festlegung 2).
func umzugStub(root string, u Umzug, inhalt, welle string) (string, error) {
	titel := TitelVon(Kopfzeile(inhalt))
	return AusVorlageAn(planningVorlagePfad(root, stubVorlageUmzug), umzugsZeigerMarke, []Ersetzung{
		{"<Titel>", titel},
		{"done/<wave-id>/<pfad-im-arbeitsbaum>", u.Neu},
		{"<wave-id | altbestand>", welle},
	})
}

// planningVorlagePfad ist der Pfad einer Stub-Vorlage unter docs/plan/planning/ —
// der Report-Stub- (ADR-0061 Festlegung 2) und der Umzugs-Stub-Vorlagen-Ort
// REPO-EIGEN (ADR-0112 Festlegung 2): anders als die zwei vendored Stub-Vorlagen
// liegen sie NICHT im Baseline-Baum, der Kurs-Satz fuehrt die Klassen nicht.
// Fehlt die Datei, faellt der Lauf mit „Vorlage fehlt" aus und erfindet keine
// Form (dieselbe AusVorlage-Setzung wie bei den zwei vendored).
func planningVorlagePfad(root string, name string) string {
	return filepath.Join(root, filepath.FromSlash(planningDir), name)
}

// reportStub baut den Stub eines Review-Reports. Die H1-Zeile kommt aus dem
// Volltext (die Identitaet ist die des Reports, die Adresse bleibt dieselbe —
// ADR-0061 Festlegung 1), der Zeiger zeigt auf den Archiv-Eintrag unter dem
// repo-relativen Pfad des Reports — demselben Pfad, an dem der Stub liegt —
// und `Archiviert mit:` nennt den Lauf, der den Report eingesammelt hat.
func reportStub(root, welle, zipRel, review, inhalt string) (string, error) {
	titel := strings.TrimSpace(rautenRE.ReplaceAllString(strings.TrimRight(Kopfzeile(inhalt), "\r"), ""))
	return AusVorlage(planningVorlagePfad(root, stubVorlageReport), []Ersetzung{
		{"<Titel>", titel},
		{"done/<wave-id>/" + archivName, zipRel},
		{"<pfad-im-archiv>", review},
		{"<wave-id | altbestand>", welle},
	})
}

// welleStub baut den Stub des Welle-Plans. Die Ergebnisnotiz bleibt vollstaendig
// und flach eine Ebene hoeher — der Zeiger auf sie steigt darum auf.
func welleStub(vorlagen string, b Bestand, wDatum, zipRel, neu, inhalt string) (string, error) {
	ergebnisBase := filepath.Base(b.Ergebnis)
	return AusVorlage(filepath.Join(vorlagen, stubVorlageWelle), []Ersetzung{
		{"<Titel>", TitelVon(Kopfzeile(inhalt))},
		{"<JJJJ-MM-TT>", wDatum},
		{"<wave-id>-results.md", "[" + ergebnisBase + "](../" + ergebnisBase + ")"},
		{"<N Slices, M Reviews>", fmt.Sprintf("%d Slices, %d Reviews", len(b.Slices()), len(b.Reviews))},
		{"done/<wave-id>/" + archivName, zipRel},
		{"<pfad-im-archiv>", neu},
		{"<wave-id>", b.Welle},
	})
}

// Zip packt die uebergebenen repo-relativen Pfade in ein Archiv unter zielRel.
// Die Eintrags-Namen sind die repo-relativen Pfade, Forward-Slash-normalisiert.
//
// ZUSAGE: zwei Laeufe ueber demselben Inhalt liefern DIESELBEN Bytes. Ein Eintrag
// traegt keinen Zeitstempel aus der Uhr des Laufs — `zip.Writer.Create` setzt
// keinen, und dieser Code setzt auch keinen. Gedeckt von
// TestZipIstUeberZweiLaeufeByteGleich.
func Zip(root, zielRel string, pfade []string) error {
	f, err := os.Create(filepath.Join(root, filepath.FromSlash(zielRel)))
	if err != nil {
		return fmt.Errorf("%s anlegen: %w", zielRel, err)
	}
	zw := zip.NewWriter(f)
	for _, rel := range pfade {
		if err := zipEintrag(zw, root, rel); err != nil {
			_, _ = zw.Close(), f.Close()
			return err
		}
	}
	// Beide Close-Fehler zaehlen: der des Writers schreibt das Zip-Verzeichnis,
	// der der Datei leert den Puffer. Ein uebergangener zweiter liesse ein
	// abgeschnittenes Archiv als Erfolg durchgehen.
	if err := zw.Close(); err != nil {
		_ = f.Close()
		return fmt.Errorf("%s abschliessen: %w", zielRel, err)
	}
	if err := f.Close(); err != nil {
		return fmt.Errorf("%s schliessen: %w", zielRel, err)
	}
	return nil
}

// zipSchreiber ist der Schreibpunkt des Archivs.
type zipSchreiber func(root, zielRel string, pfade []string) error

// pruefeArchiv oeffnet das geschriebene Zip erneut, liest jeden Eintrag bis zum
// Ende (der CRC-Vergleich liegt am Ende des Lesens) und haelt Namen und Bytes gegen
// `pfade`, die repo-relativen Quellen, die das Zip aufnehmen sollte. Befund: das
// Zip laesst sich nicht oeffnen, ein Eintrag ist nicht lesbar, traegt einen fremden
// oder doppelten Namen oder andere Bytes als seine Quelle, oder eine Quelle fehlt.
// Jede Meldung nennt das Archiv und, wo es einen gibt, den Eintrag.
func pruefeArchiv(root, zipRel string, pfade []string) error {
	zr, err := zip.OpenReader(filepath.Join(root, filepath.FromSlash(zipRel)))
	if err != nil {
		return fmt.Errorf("archiv %s nicht lesbar: %w", zipRel, err)
	}
	defer func() { _ = zr.Close() }()

	erwartet := make(map[string]bool, len(pfade))
	for _, p := range pfade {
		erwartet[filepath.ToSlash(p)] = true
	}
	gesehen := make(map[string]bool, len(pfade))
	for _, f := range zr.File {
		if !erwartet[f.Name] {
			return fmt.Errorf("archiv %s, Eintrag %s: gehoert nicht zu den Quellen", zipRel, f.Name)
		}
		if gesehen[f.Name] {
			return fmt.Errorf("archiv %s, Eintrag %s: doppelt", zipRel, f.Name)
		}
		gesehen[f.Name] = true
		rc, err := f.Open()
		if err != nil {
			return fmt.Errorf("archiv %s, Eintrag %s nicht lesbar: %w", zipRel, f.Name, err)
		}
		im, err := io.ReadAll(rc)
		_ = rc.Close()
		if err != nil {
			return fmt.Errorf("archiv %s, Eintrag %s nicht lesbar: %w", zipRel, f.Name, err)
		}
		quelle, err := os.ReadFile(filepath.Join(root, filepath.FromSlash(f.Name)))
		if err != nil {
			return fmt.Errorf("archiv %s, Eintrag %s: Quelle nicht lesbar: %w", zipRel, f.Name, err)
		}
		if !bytes.Equal(im, quelle) {
			return fmt.Errorf("archiv %s, Eintrag %s: weicht von der Quelle ab", zipRel, f.Name)
		}
	}
	for _, p := range pfade {
		if !gesehen[filepath.ToSlash(p)] {
			return fmt.Errorf("archiv %s: Eintrag %s fehlt", zipRel, filepath.ToSlash(p))
		}
	}
	return nil
}

func zipEintrag(zw *zip.Writer, root, rel string) error {
	rel = filepath.ToSlash(rel)
	w, err := zw.Create(rel)
	if err != nil {
		return fmt.Errorf("zip-Eintrag %s: %w", rel, err)
	}
	src, err := os.Open(filepath.Join(root, filepath.FromSlash(rel)))
	if err != nil {
		return fmt.Errorf("%s lesen: %w", rel, err)
	}
	defer func() { _ = src.Close() }()
	if _, err := io.Copy(w, src); err != nil {
		return fmt.Errorf("%s packen: %w", rel, err)
	}
	return nil
}

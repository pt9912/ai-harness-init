package archive

import (
	"archive/zip"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sort"
)

// Git ist die Menge der git-Operationen, die der schreibende Lauf braucht. Sie
// steht als Schnittstelle, weil die zwei Eigenschaften, die an ihr haengen —
// die Zwei-Commit-Trennung und das explizite Staging — sonst nur an einem
// echten Repo pruefbar waeren. Der Aufrufer verdrahtet `git`, der Test einen
// Mitschreiber ueber einem synthetischen Baum.
type Git interface {
	Mv(alt, neu string) error
	Rm(pfade []string) error
	Add(pfade []string) error
	Commit(nachricht string) error
}

// Umzug ist eine Datei, die der Lauf nach done/<welle-id>/ zieht — alter und
// neuer Pfad, repo-relativ und Forward-Slash-normalisiert wie in Markdown-Links.
type Umzug struct {
	Alt string
	Neu string
}

// Umzuege nennt die Dateien, die der Lauf bewegt: die eingesammelten Slices und
// den Welle-Plan. Die Review-Reports stehen NICHT darin — sie verschwinden ohne
// Stub und ohne neue Adresse.
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
// und die Dateien, deren Verweise nachgezogen wurden — und sonst nichts.
//
// ZUSAGE, und sie ist ADR-0033 Abnahme-Kriterium 2 in seiner schreibenden
// Haelfte: die Liste ist AUFGEZAEHLT, nicht `-A`. Der Inhalts-Commit ist der
// Wave-Self-Close-Punkt, den ein Audit liest; traegt er fremden Inhalt, ist die
// Zusage "der Archivierungs-Commit bezeugt die Vollstaendigkeit" gebrochen,
// ohne dass etwas rot wird. Die Loeschung der Review-Reports steht nicht darin —
// sie ist von `Rm` bereits gestagt.
// Gedeckt von TestZuStagenNenntNurArchivStubsUndNachgezogene;
// test/mutations/241-archive-welle-go-staging-explizit.sh nimmt die Aufzaehlung weg.
func ZuStagen(b Bestand, nachgezogen []string) []string {
	ziel := doneDir + "/" + b.Welle
	menge := map[string]bool{ziel + "/" + archivName: true}
	for _, u := range Umzuege(b) {
		menge[u.Neu] = true
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
// Stub-Arten aus der vendored Vorlage, das Loeschen der Review-Reports, der
// Verweis-Nachzug und Commit 2.
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
	if len(b.Plaene) != 1 {
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
	if err := g.Commit("archive-welle: " + b.Welle + "  Zeitdokumente nach " + ziel + "/ (reiner Move)"); err != nil {
		return err
	}

	// Ab hier traegt der Baum Commit 1. Jeder Fehler bekommt den Rueckweg mit.
	if err := inhaltsSchritt(root, b, dateien, vorlagen, umzuege, g, out); err != nil {
		return NachCommit1Fehler{Welle: b.Welle, Ziel: ziel, Ursache: err}
	}
	return nil
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

// inhaltsSchritt ist alles, was in Commit 2 landet: Zip, Stubs, Loeschung der
// Review-Reports, Verweis-Nachzug, Staging.
func inhaltsSchritt(root string, b Bestand, dateien []string, vorlagen string, umzuege []Umzug, g Git, out io.Writer) error {
	ziel := doneDir + "/" + b.Welle
	zipRel := ziel + "/" + archivName

	// Das Zip entsteht VOR den Stubs: an den neuen Pfaden liegt noch der
	// Volltext, den es aufnimmt.
	imArchiv := make([]string, 0, len(umzuege)+len(b.Reviews))
	for _, u := range umzuege {
		imArchiv = append(imArchiv, u.Neu)
	}
	imArchiv = append(imArchiv, b.Reviews...)
	if err := Zip(root, zipRel, imArchiv); err != nil {
		return err
	}

	if err := schreibeStubs(root, b, vorlagen, umzuege, zipRel); err != nil {
		return err
	}

	if len(b.Reviews) > 0 {
		if err := g.Rm(b.Reviews); err != nil {
			return err
		}
	}

	nachgezogen, err := Nachziehen(root, dateien, b.Bewegte(), b.Welle)
	if err != nil {
		return err
	}
	beruehrt := make([]string, 0, len(nachgezogen))
	for _, f := range nachgezogen {
		beruehrt = append(beruehrt, f.Datei)
	}
	if err := g.Add(ZuStagen(b, beruehrt)); err != nil {
		return err
	}
	if err := g.Commit("archive-welle: " + b.Welle + "  Archiv, Stubs und Verweis-Nachzug (Inhalt, getrennt vom Move — AGENTS.md §3.3)"); err != nil {
		return err
	}

	groesse, _ := os.Stat(filepath.Join(root, filepath.FromSlash(zipRel)))
	fmt.Fprintf(out, "archive-welle ok: %s\n", b.Welle)
	fmt.Fprintf(out, "  Commit 1 (reiner Move): %d Slice(s) + Welle-Plan nach %s/\n", len(b.Slices()), ziel)
	bytes := int64(0)
	if groesse != nil {
		bytes = groesse.Size()
	}
	fmt.Fprintf(out, "  Commit 2 (Inhalt): %s (%d Bytes), %d Stub(s), %d Review-Report(s) entfernt\n",
		archivName, bytes, len(umzuege), len(b.Reviews))
	// Dieselbe Zeile wie in der Vorschau, aus derselben Funktion: zwei Fassungen
	// derselben Ausgabe drifteten.
	schreibeVerweise(out, nachgezogen)
	fmt.Fprintln(out, "  Naechster Schritt: make docs-check — er zeigt, was der Nachzug nicht erreicht.")
	return nil
}

// schreibeStubs ersetzt jede bewegte Datei durch ihren Stub. Der Welle-Plan
// bekommt die Welle-Vorlage, jeder Slice die Slice-Vorlage; Review-Reports
// bekommen keinen — sie haben keine Identitaet jenseits ihres Slice.
func schreibeStubs(root string, b Bestand, vorlagen string, umzuege []Umzug, zipRel string) error {
	planBase := filepath.Base(b.Plaene[0])
	planNeu := doneDir + "/" + b.Welle + "/" + planBase

	ergebnis, _, err := lies(root, b.Ergebnis)
	if err != nil {
		return err
	}
	wDatum := WelleDatum(ergebnis)

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
		{"<NNN>", nummer},
		{"<Titel>", TitelVon(Kopfzeile(inhalt))},
		{"<welle-id | ohne Welle>", welleFeld},
		{"<JJJJ-MM-TT>", GeschlossenDatum(inhalt, wDatum)},
		{"<BEO-*, ADR-*, Folge-Slice — oder `— keine —`>", Hervorgegangen(root, inhalt, b.Welle)},
		{"done/<welle-id>/" + archivName, zipRel},
		{"<pfad-im-archiv>", neu},
		{"<welle-id>", b.Welle},
	})
}

// welleStub baut den Stub des Welle-Plans. Die Ergebnisnotiz bleibt vollstaendig
// und flach eine Ebene hoeher — der Zeiger auf sie steigt darum auf.
func welleStub(vorlagen string, b Bestand, wDatum, zipRel, neu, inhalt string) (string, error) {
	ergebnisBase := filepath.Base(b.Ergebnis)
	return AusVorlage(filepath.Join(vorlagen, stubVorlageWelle), []Ersetzung{
		{"<Titel>", TitelVon(Kopfzeile(inhalt))},
		{"<JJJJ-MM-TT>", wDatum},
		{"<welle-id>-results.md", "[" + ergebnisBase + "](../" + ergebnisBase + ")"},
		{"<N Slices, M Reviews>", fmt.Sprintf("%d Slices, %d Reviews", len(b.Slices()), len(b.Reviews))},
		{"done/<welle-id>/" + archivName, zipRel},
		{"<pfad-im-archiv>", neu},
		{"<welle-id>", b.Welle},
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

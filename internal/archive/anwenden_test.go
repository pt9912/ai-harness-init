package archive_test

import (
	"archive/zip"
	"bytes"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/archive"
)

// gitMitschreiber ist die Test-Verdrahtung der vier git-Operationen: `Mv` und
// `Rm` bewegen den synthetischen Baum wirklich (die folgenden Schritte muessen
// die Dateien an ihrer neuen Adresse finden), `Add` und `Commit` schreiben mit.
//
// Bei JEDEM Commit haelt er einen Schnappschuss fest: den Inhalt der beobachteten
// Datei und ob das Archiv schon liegt. Daran ist die Zwei-Commit-Trennung
// messbar, ohne ein Repo zu bewegen.
type gitMitschreiber struct {
	root      string
	beobachte string // repo-relativer Pfad, dessen Inhalt je Commit festgehalten wird
	zipPfad   string

	rufe      []string
	addPfade  []string
	commits   []string
	inhalte   []string
	zipDaLage []bool
}

func (g *gitMitschreiber) Mv(alt, neu string) error {
	g.rufe = append(g.rufe, "mv")
	ziel := filepath.Join(g.root, filepath.FromSlash(neu))
	if err := os.MkdirAll(filepath.Dir(ziel), 0o755); err != nil {
		return err
	}
	return os.Rename(filepath.Join(g.root, filepath.FromSlash(alt)), ziel)
}

func (g *gitMitschreiber) Rm(pfade []string) error {
	g.rufe = append(g.rufe, "rm")
	for _, p := range pfade {
		if err := os.Remove(filepath.Join(g.root, filepath.FromSlash(p))); err != nil {
			return err
		}
	}
	return nil
}

func (g *gitMitschreiber) Add(pfade []string) error {
	g.rufe = append(g.rufe, "add")
	g.addPfade = append(g.addPfade, pfade...)
	return nil
}

func (g *gitMitschreiber) Commit(nachricht string) error {
	g.rufe = append(g.rufe, "commit")
	g.commits = append(g.commits, nachricht)
	b, _ := os.ReadFile(filepath.Join(g.root, filepath.FromSlash(g.beobachte)))
	g.inhalte = append(g.inhalte, string(b))
	_, err := os.Stat(filepath.Join(g.root, filepath.FromSlash(g.zipPfad)))
	g.zipDaLage = append(g.zipDaLage, err == nil)
	return nil
}

const volltextSlice100 = `# Slice slice-100: Der erste Gegenstand

**Welle:** welle-10

## 7. Closure-Notiz

**Rolle:** Planner · **Datum:** 2026-05-05

- **Beobachtungs-Register:** BEO-009 auf 9x erhoeht
- **Folge-Slices:** slice-176 (Nachfolger)
`

const volltextSlice101 = `# Slice slice-101: Der wellenlose

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD

## 7. Closure-Notiz

- **Folge-Slices:** keine
`

const volltextSlice102 = `# Slice slice-102: Der fremde

**Welle:** welle-11

## 1. Ziel
`

const volltextPlan = `# Welle welle-10: Der Wellen-Titel

## 1. Ziel

Etwas.
`

// baueBaum legt den synthetischen Repo-Baum an: eine geschlossene welle-10 mit
// einem Mitglied, einem wellenlosen und einem fremden Slice, Welle-Plan,
// Ergebnisnotiz, einem Review-Report und je einem Verweis in allen drei Formen.
func baueBaum(t *testing.T) string {
	t.Helper()
	root := t.TempDir()
	vorlagenBaum(t, root)
	done := filepath.Join(root, "docs", "plan", "planning", "done")
	schreibe(t, filepath.Join(done, "welle-10-eine-welle.md"), volltextPlan)
	schreibe(t, filepath.Join(done, "welle-10-results.md"),
		"# welle-10 — Ergebnisse\n\n**Abschluss:** 2026-06-06\n\nGeliefert: [slice-100](slice-100-a.md).\n")
	schreibe(t, filepath.Join(done, "slice-100-a.md"), volltextSlice100)
	schreibe(t, filepath.Join(done, "slice-101-b.md"), volltextSlice101)
	schreibe(t, filepath.Join(done, "slice-102-c.md"), volltextSlice102)
	schreibe(t, filepath.Join(done, "welle-09", archivNameTest), "PK-Attrappe\n")
	schreibe(t, filepath.Join(root, "docs", "reviews", "2026-05-05-slice-100-runde-1.md"), "# Review\n")
	schreibe(t, filepath.Join(root, "docs", "plan", "adr", "0033-x.md"),
		"Siehe [slice-100](../planning/done/slice-100-a.md).\n")
	// Untrackter Fremdbestand: er liegt im Baum, steht aber in keiner ls-files-Liste
	// und darf in keinem Staging auftauchen.
	schreibe(t, filepath.Join(root, "fremd.txt"), "gehoert niemandem\n")
	return root
}

const archivNameTest = "archiv.zip"

// indexDateien ist der Suchraum-Eingang, den der Aufrufer im Betrieb aus
// `git ls-files` bekommt: jede getrackte Datei. Die Attrappe fuehrt jede Datei
// des Baums AUSSER fremd.txt — genau die Trennung, die im Betrieb der Index
// zieht.
func indexDateien(t *testing.T, root string) []string {
	t.Helper()
	var out []string
	err := filepath.WalkDir(root, func(p string, d fs.DirEntry, err error) error {
		if err != nil || d.IsDir() {
			return err
		}
		rel, rerr := filepath.Rel(root, p)
		if rerr != nil {
			return rerr
		}
		rel = filepath.ToSlash(rel)
		if rel == "fremd.txt" {
			return nil
		}
		out = append(out, rel)
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
	sort.Strings(out)
	return out
}

func einsammeln(t *testing.T, root, welle string) archive.Bestand {
	t.Helper()
	b, err := archive.Einsammeln(root, welle)
	if err != nil {
		t.Fatal(err)
	}
	return b
}

// TestAnwendenTrenntMoveVonInhalt misst AGENTS.md 3.3 am Lauf selbst: Commit 1
// sieht die bewegte Datei mit ihrem VOLLEN Text und ohne Archiv daneben — kein
// Byte Inhalt —, Commit 2 sieht den Stub und das Archiv. Faellt die Trennung, ist
// die Rename-Erkennung unter der Aehnlichkeits-Schwelle und die Herkunft der
// archivierten Datei aus dem Log nicht mehr ablesbar.
//
// Gegenbeispiel: den ersten Commit-Aufruf hinter den Inhalts-Schritt ziehen —
// dann traegt der erste Schnappschuss den Stub.
func TestAnwendenTrenntMoveVonInhalt(t *testing.T) {
	root := baueBaum(t)
	b := einsammeln(t, root, "welle-10")
	g := &gitMitschreiber{
		root:      root,
		beobachte: "docs/plan/planning/done/welle-10/slice-100-a.md",
		zipPfad:   "docs/plan/planning/done/welle-10/" + archivNameTest,
	}
	var aus bytes.Buffer
	if err := archive.Anwenden(root, b, indexDateien(t, root), g, &aus); err != nil {
		t.Fatal(err)
	}

	wantRufe := []string{"mv", "mv", "mv", "commit", "rm", "add", "commit"}
	if strings.Join(g.rufe, ",") != strings.Join(wantRufe, ",") {
		t.Fatalf("git-Aufrufe = %v, want %v", g.rufe, wantRufe)
	}
	if len(g.inhalte) != 2 {
		t.Fatalf("%d Commits, want 2", len(g.inhalte))
	}
	if g.inhalte[0] != volltextSlice100 {
		t.Errorf("Commit 1 sieht nicht den Volltext:\n%q", g.inhalte[0])
	}
	if g.zipDaLage[0] {
		t.Error("Commit 1 sieht das Archiv — der Move-Commit traegt damit Inhalt")
	}
	if !strings.Contains(g.inhalte[1], "> **ARCHIVIERT**") {
		t.Errorf("Commit 2 sieht keinen Stub:\n%q", g.inhalte[1])
	}
	if !g.zipDaLage[1] {
		t.Error("Commit 2 sieht das Archiv nicht")
	}
	if !strings.Contains(g.commits[0], "reiner Move") || !strings.Contains(g.commits[1], "§3.3") {
		t.Errorf("Commit-Nachrichten benennen die Trennung nicht: %q / %q", g.commits[0], g.commits[1])
	}
}

// TestZuStagenNenntNurArchivStubsUndNachgezogene ist ADR-0033 Abnahme-Kriterium 2
// in seiner schreibenden Haelfte: der Inhalts-Commit stagt eine AUFGEZAEHLTE
// Liste — Archiv, Stubs, nachgezogene Dateien — und nichts sonst. Der untrackte
// Fremdbestand liegt im Baum und steht in keiner davon.
// Gegenbeispiel: test/mutations/241-archive-welle-go-staging-explizit.sh.
func TestZuStagenNenntNurArchivStubsUndNachgezogene(t *testing.T) {
	root := baueBaum(t)
	b := einsammeln(t, root, "welle-10")
	g := &gitMitschreiber{root: root,
		beobachte: "docs/plan/planning/done/welle-10/slice-100-a.md",
		zipPfad:   "docs/plan/planning/done/welle-10/" + archivNameTest}
	var aus bytes.Buffer
	if err := archive.Anwenden(root, b, indexDateien(t, root), g, &aus); err != nil {
		t.Fatal(err)
	}
	got := append([]string{}, g.addPfade...)
	sort.Strings(got)
	want := []string{
		"docs/plan/adr/0033-x.md",
		"docs/plan/planning/done/welle-10-results.md",
		"docs/plan/planning/done/welle-10/archiv.zip",
		"docs/plan/planning/done/welle-10/slice-100-a.md",
		"docs/plan/planning/done/welle-10/slice-101-b.md",
		"docs/plan/planning/done/welle-10/welle-10-eine-welle.md",
	}
	if strings.Join(got, "\n") != strings.Join(want, "\n") {
		t.Fatalf("gestagte Pfade =\n%s\nwant\n%s", strings.Join(got, "\n"), strings.Join(want, "\n"))
	}
	for _, p := range got {
		if p == "fremd.txt" || p == "-A" || p == "." {
			t.Fatalf("Staging greift ueber die Aufzaehlung hinaus: %q", p)
		}
	}
}

// TestAnwendenSchreibtBeideStubArtenAusDerVorlage haelt ADR-0033 Festlegung 3:
// die Form kommt aus der Datei. Der Marker der Prueftext-Vorlage steht in keiner
// echten und in keinem Code — er kann nur aus der gelesenen Vorlage kommen. Dass
// er im STUB nicht mehr steht, ist die Kuerzung; dass der Lauf ohne die Vorlage
// faellt, ist TestAnwendenOhneVorlageNenntDenRueckweg.
func TestAnwendenSchreibtBeideStubArtenAusDerVorlage(t *testing.T) {
	root := baueBaum(t)
	b := einsammeln(t, root, "welle-10")
	g := &gitMitschreiber{root: root,
		beobachte: "docs/plan/planning/done/welle-10/slice-100-a.md",
		zipPfad:   "docs/plan/planning/done/welle-10/" + archivNameTest}
	var aus bytes.Buffer
	if err := archive.Anwenden(root, b, indexDateien(t, root), g, &aus); err != nil {
		t.Fatal(err)
	}

	mitglied := lesen(t, root, "docs/plan/planning/done/welle-10/slice-100-a.md")
	wantMitglied := "# slice-100 — Der erste Gegenstand\n" +
		"\n" +
		"> **ARCHIVIERT** — Volltext:\n" +
		"> `unzip -p docs/plan/planning/done/welle-10/archiv.zip docs/plan/planning/done/welle-10/slice-100-a.md`\n" +
		"\n" +
		"**Welle:** [welle-10](welle-10-eine-welle.md)\n" +
		"**Archiviert mit:** welle-10 · **Geschlossen:** 2026-05-05\n" +
		// Der Folge-Slice slice-176 liegt in diesem Baum nirgends — er steht
		// darum ohne Link statt mit einem toten.
		"**Hervorgegangen:** [`BEO-009`](../../observations.md) · slice-176\n"
	if mitglied != wantMitglied {
		t.Errorf("Slice-Stub (Mitglied) =\n%q\nwant\n%q", mitglied, wantMitglied)
	}

	wellenlos := lesen(t, root, "docs/plan/planning/done/welle-10/slice-101-b.md")
	if !strings.Contains(wellenlos, "**Welle:** ohne Welle\n") {
		t.Errorf("wellenloser Stub traegt die Zugehoerigkeit falsch:\n%q", wellenlos)
	}
	if !strings.Contains(wellenlos, "**Archiviert mit:** welle-10 · **Geschlossen:** 2026-06-06\n") {
		t.Errorf("wellenloser Stub: ohne eigenes Datum gilt das der Welle:\n%q", wellenlos)
	}

	plan := lesen(t, root, "docs/plan/planning/done/welle-10/welle-10-eine-welle.md")
	wantPlan := "# welle-10 — Der Wellen-Titel\n" +
		"\n" +
		"> **ARCHIVIERT** — Volltext:\n" +
		"> `unzip -p docs/plan/planning/done/welle-10/archiv.zip docs/plan/planning/done/welle-10/welle-10-eine-welle.md`\n" +
		"\n" +
		"**Geschlossen:** 2026-06-06 · **Ergebnisnotiz:** [welle-10-results.md](../welle-10-results.md)\n" +
		"**Archivierte Vorgänge:** 2 Slices, 1 Reviews\n"
	if plan != wantPlan {
		t.Errorf("Welle-Stub =\n%q\nwant\n%q", plan, wantPlan)
	}

	for _, p := range []string{
		"docs/plan/planning/done/welle-10/slice-100-a.md",
		"docs/plan/planning/done/welle-10/welle-10-eine-welle.md",
	} {
		if strings.Contains(lesen(t, root, p), vorlagenMarker) {
			t.Errorf("%s traegt den Vorlagen-Hinweis — die Kuerzung hat ihn nicht genommen", p)
		}
	}
	// Der fremde Slice bleibt liegen, der Review-Report ist ohne Stub verschwunden.
	if _, err := os.Stat(filepath.Join(root, "docs", "plan", "planning", "done", "slice-102-c.md")); err != nil {
		t.Errorf("der fremde Slice ist nicht liegen geblieben: %v", err)
	}
	if _, err := os.Stat(filepath.Join(root, "docs", "reviews", "2026-05-05-slice-100-runde-1.md")); !os.IsNotExist(err) {
		t.Errorf("der Review-Report liegt noch: %v", err)
	}
}

// TestAnwendenPacktJedesZeitdokumentInsArchiv: das Zip traegt die drei bewegten
// Dateien und den Review-Report unter ihren repo-relativen Pfaden — die Adresse,
// die der Stub als `unzip -p`-Zeiger abdruckt.
func TestAnwendenPacktJedesZeitdokumentInsArchiv(t *testing.T) {
	root := baueBaum(t)
	b := einsammeln(t, root, "welle-10")
	g := &gitMitschreiber{root: root,
		beobachte: "docs/plan/planning/done/welle-10/slice-100-a.md",
		zipPfad:   "docs/plan/planning/done/welle-10/" + archivNameTest}
	var aus bytes.Buffer
	if err := archive.Anwenden(root, b, indexDateien(t, root), g, &aus); err != nil {
		t.Fatal(err)
	}
	zr, err := zip.OpenReader(filepath.Join(root, "docs", "plan", "planning", "done", "welle-10", archivNameTest))
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = zr.Close() }()
	got := map[string]string{}
	for _, f := range zr.File {
		rc, err := f.Open()
		if err != nil {
			t.Fatal(err)
		}
		var buf bytes.Buffer
		if _, err := buf.ReadFrom(rc); err != nil {
			t.Fatal(err)
		}
		_ = rc.Close()
		got[f.Name] = buf.String()
	}
	want := []string{
		"docs/plan/planning/done/welle-10/slice-100-a.md",
		"docs/plan/planning/done/welle-10/slice-101-b.md",
		"docs/plan/planning/done/welle-10/welle-10-eine-welle.md",
		"docs/reviews/2026-05-05-slice-100-runde-1.md",
	}
	if len(got) != len(want) {
		t.Fatalf("Zip traegt %d Eintraege, want %d", len(got), len(want))
	}
	for _, w := range want {
		if _, drin := got[w]; !drin {
			t.Errorf("Zip-Eintrag fehlt: %s", w)
		}
	}
	if got["docs/plan/planning/done/welle-10/slice-100-a.md"] != volltextSlice100 {
		t.Error("das Archiv traegt nicht den Volltext, sondern etwas anderes")
	}
}

// TestZipIstUeberZweiLaeufeByteGleich misst die Eigenschaft, die der
// git-archive-Weg ueber einen Tree-Operanden hatte und die hier aus der
// Standardbibliothek kommt: kein Eintrag traegt einen Zeitstempel aus der Uhr des
// Laufs, also liefern zwei Laeufe ueber demselben Inhalt dieselben Bytes
// (LH-QA-02). Gegenbeispiel: einem Eintrag ein `Modified` setzen.
func TestZipIstUeberZweiLaeufeByteGleich(t *testing.T) {
	root := t.TempDir()
	schreibe(t, filepath.Join(root, "a.md"), "Inhalt A\n")
	schreibe(t, filepath.Join(root, "b.md"), "Inhalt B\n")
	var bytesJeLauf [2][]byte
	for i := range bytesJeLauf {
		if err := archive.Zip(root, "lauf.zip", []string{"a.md", "b.md"}); err != nil {
			t.Fatal(err)
		}
		b, err := os.ReadFile(filepath.Join(root, "lauf.zip"))
		if err != nil {
			t.Fatal(err)
		}
		bytesJeLauf[i] = b
	}
	if !bytes.Equal(bytesJeLauf[0], bytesJeLauf[1]) {
		t.Fatalf("zwei Laeufe liefern verschiedene Bytes (%d vs. %d)", len(bytesJeLauf[0]), len(bytesJeLauf[1]))
	}
}

// TestAnwendenOhneVorlageNenntDenRueckweg: faellt die Stub-Erzeugung, ist der
// Baum zwischen den zwei Commits — Move committet, Archiv und Stubs ungestagt.
// Ein zweiter Aufruf scheitert dann an zwei eigenen Vorpruefungen zugleich, also
// nennt der Fehler den Weg zurueck.
func TestAnwendenOhneVorlageNenntDenRueckweg(t *testing.T) {
	root := baueBaum(t)
	weg := filepath.Join(root, ".harness", "baseline", pruefTag, "templates",
		"docs", "plan", "planning", "archiv-stub-slice.template.md")
	if err := os.Remove(weg); err != nil {
		t.Fatal(err)
	}
	b := einsammeln(t, root, "welle-10")
	g := &gitMitschreiber{root: root,
		beobachte: "docs/plan/planning/done/welle-10/slice-100-a.md",
		zipPfad:   "docs/plan/planning/done/welle-10/" + archivNameTest}
	var aus bytes.Buffer
	err := archive.Anwenden(root, b, indexDateien(t, root), g, &aus)
	if err == nil {
		t.Fatal("ohne Slice-Vorlage kein Fehler")
	}
	for _, teil := range []string{"Abbruch nach Commit 1", "Vorlage fehlt", "git reset --hard HEAD~1"} {
		if !strings.Contains(err.Error(), teil) {
			t.Errorf("Fehlertext nennt %q nicht:\n%v", teil, err)
		}
	}
	if len(g.commits) != 1 {
		t.Errorf("%d Commits, want 1 (nur der Move)", len(g.commits))
	}
}

// vorlageSliceOhneZeiger ist die Slice-Vorlage ohne ihren Archiv-Zeiger-Block.
// Der Stub, der daraus entsteht, ist form-widrig — genau der Zustand, gegen den
// FormOK im Lauf steht.
const vorlageSliceOhneZeiger = `# slice-<NNN> — <Titel>

> **Template-Hinweis.** ` + vorlagenMarker + ` — dieser Absatz faellt beim Kuerzen weg.

**Welle:** <welle-id | ohne Welle>
**Archiviert mit:** <welle-id> · **Geschlossen:** <JJJJ-MM-TT>
**Hervorgegangen:** <BEO-*, ADR-*, Folge-Slice — oder ` + "`— keine —`" + `>
`

// TestAnwendenBrichtBeiVerletzterStubFormAb misst die VERDRAHTUNG von FormOK,
// nicht ihre Logik: dass der Lauf sie zwischen Stub-Erzeugung und Schreibzugriff
// ruft und an ihrem Urteil abbricht. Die Logik selbst deckt
// TestFormOKMeldetStehengebliebeneUeberschrift — ein Test ueber der Funktion
// bleibt gruen, wenn niemand sie mehr aufruft.
//
// Vier Pruefungen, und die letzte ist die tragende: die bewegte Datei traegt
// nach dem Abbruch noch ihren VOLLTEXT. Damit ist gemessen, dass FormOK VOR dem
// os.WriteFile steht und nicht dahinter — ein Lauf, der erst schriebe und dann
// urteilte, liesse den form-widrigen Stub im Baum.
//
// Der Abbruch liegt ZWISCHEN den zwei Commits (harness/README.md: „eine
// verletzte Stub-Form bricht zwischen den zwei Commits ab und nennt den
// Rueckweg") — darum steht der Rueckweg im Fehlertext und der Move-Commit
// alleine da.
// Gegenbeispiel: test/mutations/243-archive-welle-go-stubform-verdrahtung.sh.
func TestAnwendenBrichtBeiVerletzterStubFormAb(t *testing.T) {
	root := baueBaum(t)
	schreibe(t, filepath.Join(root, ".harness", "baseline", pruefTag, "templates",
		"docs", "plan", "planning", "archiv-stub-slice.template.md"), vorlageSliceOhneZeiger)
	b := einsammeln(t, root, "welle-10")
	g := &gitMitschreiber{root: root,
		beobachte: "docs/plan/planning/done/welle-10/slice-100-a.md",
		zipPfad:   "docs/plan/planning/done/welle-10/" + archivNameTest}
	var aus bytes.Buffer

	err := archive.Anwenden(root, b, indexDateien(t, root), g, &aus)

	if err == nil {
		t.Fatal("form-widriger Stub: want Fehler, got nil — FormOK ist nicht verdrahtet")
	}
	for _, teil := range []string{"kein Archiv-Zeiger", "Abbruch nach Commit 1", "git reset --hard HEAD~1"} {
		if !strings.Contains(err.Error(), teil) {
			t.Errorf("Fehlertext nennt %q nicht:\n%v", teil, err)
		}
	}
	if len(g.commits) != 1 {
		t.Errorf("%d Commits, want 1 (nur der Move — der Inhalts-Commit kommt nicht mehr)", len(g.commits))
	}
	if got := lesen(t, root, "docs/plan/planning/done/welle-10/slice-100-a.md"); got != volltextSlice100 {
		t.Errorf("der form-widrige Stub steht im Baum — FormOK laeuft nach dem Schreibzugriff:\n%q", got)
	}
}

// TestZweiterLaufZiehtDenAufsteigendenStubVerweisNach ist ADR-0033
// Abnahme-Kriterium 3, gefahren als das, was es ist: ZWEI Laeufe. Der erste
// archiviert welle-09 und schreibt dabei selbst einen Verweis der aufsteigenden
// Form — der Folge-Slice slice-100 liegt noch flach in done/, also steht im Stub
// `](../slice-100-a.md)`. Der zweite archiviert welle-10 und zieht slice-100 eine
// Ebene tiefer; ohne die aufsteigende Ersetzungsrichtung zeigte der Verweis
// danach ins Leere, und keine der beiden anderen Regeln erreichte ihn.
// Gegenbeispiel: test/mutations/240-archive-welle-go-aufsteigender-verweis.sh.
func TestZweiterLaufZiehtDenAufsteigendenStubVerweisNach(t *testing.T) {
	root := baueBaum(t)
	done := filepath.Join(root, "docs", "plan", "planning", "done")
	schreibe(t, filepath.Join(done, "welle-09-vorwelle.md"), "# Welle welle-09: Die Vorwelle\n\n## 1. Ziel\n")
	schreibe(t, filepath.Join(done, "welle-09-results.md"), "# welle-09 — Ergebnisse\n\n**Abschluss:** 2026-04-04\n")
	schreibe(t, filepath.Join(done, "slice-090-x.md"),
		"# Slice slice-090: Der Vorgaenger\n\n**Welle:** welle-09\n\n## 7. Closure-Notiz\n\n- **Folge-Slices:** slice-100 (Nachfolger)\n")
	// Das Archiv-Verzeichnis der Vorwelle wird von diesem Lauf selbst angelegt;
	// die Attrappe aus baueBaum liegt im Weg.
	if err := os.RemoveAll(filepath.Join(done, "welle-09")); err != nil {
		t.Fatal(err)
	}

	lauf := func(welle string) *gitMitschreiber {
		t.Helper()
		b := einsammeln(t, root, welle)
		g := &gitMitschreiber{root: root,
			beobachte: "docs/plan/planning/done/" + welle + "/" + archivNameTest,
			zipPfad:   "docs/plan/planning/done/" + welle + "/" + archivNameTest}
		var aus bytes.Buffer
		if err := archive.Anwenden(root, b, indexDateien(t, root), g, &aus); err != nil {
			t.Fatalf("%s: %v", welle, err)
		}
		return g
	}

	lauf("welle-09")
	stub := "docs/plan/planning/done/welle-09/slice-090-x.md"
	nachLauf1 := lesen(t, root, stub)
	if !strings.Contains(nachLauf1, "[slice-100](../slice-100-a.md)") {
		t.Fatalf("Lauf 1 schreibt die aufsteigende Form nicht:\n%s", nachLauf1)
	}

	g2 := lauf("welle-10")
	nachLauf2 := lesen(t, root, stub)
	if !strings.Contains(nachLauf2, "[slice-100](../welle-10/slice-100-a.md)") {
		t.Fatalf("Lauf 2 zieht den aufsteigenden Verweis nicht nach:\n%s", nachLauf2)
	}
	gestagt := strings.Join(g2.addPfade, "\n")
	if !strings.Contains(gestagt, stub) {
		t.Fatalf("die nachgezogene Datei ist nicht gestagt:\n%s", gestagt)
	}
}

func lesen(t *testing.T, root, rel string) string {
	t.Helper()
	b, err := os.ReadFile(filepath.Join(root, filepath.FromSlash(rel)))
	if err != nil {
		t.Fatal(err)
	}
	return string(b)
}

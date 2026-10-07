package main

import (
	"archive/zip"
	"bytes"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"testing"
)

// gitBewegend ist die Test-Verdrahtung der vier schreibenden git-Operationen
// ueber einem synthetischen Baum: Mv und Rm bewegen wirklich (die Schritte
// danach finden die Dateien an der neuen Adresse), Add und Commit schreiben mit.
type gitBewegend struct {
	root    string
	rufe    []string
	commits []string
}

func (g *gitBewegend) Mv(alt, neu string) error {
	g.rufe = append(g.rufe, "mv")
	ziel := filepath.Join(g.root, filepath.FromSlash(neu))
	if err := os.MkdirAll(filepath.Dir(ziel), 0o755); err != nil {
		return err
	}
	return os.Rename(filepath.Join(g.root, filepath.FromSlash(alt)), ziel)
}

func (g *gitBewegend) Rm(pfade []string) error {
	g.rufe = append(g.rufe, "rm")
	for _, p := range pfade {
		if err := os.Remove(filepath.Join(g.root, filepath.FromSlash(p))); err != nil {
			return err
		}
	}
	return nil
}

func (g *gitBewegend) Add([]string) error { g.rufe = append(g.rufe, "add"); return nil }

func (g *gitBewegend) Commit(nachricht string) error {
	g.rufe = append(g.rufe, "commit")
	g.commits = append(g.commits, nachricht)
	return nil
}

const altbestandStub = "# <Titel>\n\n> **ARCHIVIERT** — Volltext:\n" +
	"> `unzip -p done/<welle-id>/archiv.zip <pfad-im-archiv>`\n\n" +
	"**Welle:** <welle-id | ohne Welle>\n" +
	"**Archiviert mit:** <welle-id> · **Geschlossen:** <JJJJ-MM-TT>\n"

const doneRel = "docs/plan/planning/done/"

// altbestandBaum: zwei wellenlose Slices mit je einem Review-Report, ein
// Mitglied und ein Plan von welle-10 samt Ergebnisnotiz (bleiben flach), ein
// fremder Slice (bleibt flach). Kein done/*/archiv.zip: die Untergrenze fehlt.
func altbestandBaum(t *testing.T) string {
	t.Helper()
	root := t.TempDir()
	vorlagen := ".harness/baseline/v9.99.0/templates/docs/plan/planning/"
	schreibeDatei(t, root, vorlagen+"archiv-stub-slice.template.md", altbestandStub)
	schreibeDatei(t, root, vorlagen+"archiv-stub-welle.template.md", altbestandStub)
	schreibeDatei(t, root, doneRel+"slice-100-a.md", "# Slice slice-100: A\n\n**Welle:** ohne Welle\n")
	schreibeDatei(t, root, doneRel+"slice-101-b.md", "# Slice slice-101: B\n\n**Welle:** ohne Welle — DoD\n")
	schreibeDatei(t, root, doneRel+"slice-102-c.md", "# Slice slice-102: C\n\n**Welle:** welle-10\n")
	schreibeDatei(t, root, doneRel+"slice-103-d.md", "# Slice slice-103: D\n\n**Welle:** welle-11\n")
	schreibeDatei(t, root, doneRel+"welle-10-eine-welle.md", "# Welle welle-10: W\n\n## 1. Ziel\n")
	schreibeDatei(t, root, doneRel+"welle-10-results.md", "# welle-10 — Ergebnisse\n\n**Abschluss:** 2026-06-06\n")
	schreibeDatei(t, root, "docs/reviews/2026-05-05-slice-100-r1.md", "# Review 100\n")
	schreibeDatei(t, root, "docs/reviews/2026-05-06-slice-101-r1.md", "# Review 101\n")
	return root
}

func zahlAus(t *testing.T, ausgabe, label string) int {
	t.Helper()
	m := regexp.MustCompile(regexp.QuoteMeta(label) + `\s*(\d+)`).FindStringSubmatch(ausgabe)
	if m == nil {
		t.Fatalf("Zeile %q fehlt in der Ausgabe:\n%s", label, ausgabe)
	}
	n, _ := strconv.Atoi(m[1])
	return n
}

func zipEintraege(t *testing.T, pfad string) []string {
	t.Helper()
	zr, err := zip.OpenReader(pfad)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = zr.Close() }()
	var out []string
	for _, f := range zr.File {
		out = append(out, f.Name)
	}
	return out
}

func flacheMd(t *testing.T, root string) []string {
	t.Helper()
	treffer, err := filepath.Glob(filepath.Join(root, "docs", "plan", "planning", "done", "*.md"))
	if err != nil {
		t.Fatal(err)
	}
	var out []string
	for _, p := range treffer {
		out = append(out, filepath.Base(p))
	}
	return out
}

// TestArchiveWelleAltbestandSchreibtDieMengeDerVorschau haelt L1 des Slice:
// der schreibende Lauf ueber `altbestand` bewegt, packt und stubt genau die
// Menge, die die Vorschau desselben Baums nennt, in zwei Commits, und laesst
// Welle-Plan, Ergebnisnotiz, Mitglied und fremden Slice flach liegen.
func TestArchiveWelleAltbestandSchreibtDieMengeDerVorschau(t *testing.T) {
	root := altbestandBaum(t)
	dateien := indexAttrappe(t, root)

	var vorschau, errb bytes.Buffer
	if code := archiveWelleLauf(root, einCommit(t, root), "altbestand", true, "", dateien, &gitBewegend{root: root}, &vorschau, &errb); code != 0 {
		t.Fatalf("Vorschau Exit %d, want 0:\n%s%s", code, vorschau.String(), errb.String())
	}
	wellenlos := zahlAus(t, vorschau.String(), "wellenlos (seit der letzten Closure):")
	reviews := zahlAus(t, vorschau.String(), "Review-Reports (ohne Stub):")
	if wellenlos != 2 || reviews != 2 {
		t.Fatalf("Vorbedingung des Baums: wellenlos=%d reviews=%d, want 2/2", wellenlos, reviews)
	}

	g := &gitBewegend{root: root}
	var out bytes.Buffer
	if code := archiveWelleLauf(root, einCommit(t, root), "altbestand", false, "", dateien, g, &out, &errb); code != 0 {
		t.Fatalf("Lauf Exit %d, want 0:\n%s%s", code, out.String(), errb.String())
	}

	stubs, _ := filepath.Glob(filepath.Join(root, "docs", "plan", "planning", "done", "altbestand", "*.md"))
	if len(stubs) != wellenlos {
		t.Errorf("%d Stubs unter done/altbestand/, die Vorschau nannte %d wellenlose", len(stubs), wellenlos)
	}
	eintraege := zipEintraege(t, filepath.Join(root, "docs", "plan", "planning", "done", "altbestand", "archiv.zip"))
	var imArchivReviews, imArchivSlices int
	for _, e := range eintraege {
		switch {
		case strings.HasPrefix(e, "docs/reviews/"):
			imArchivReviews++
		case strings.HasPrefix(e, "docs/plan/planning/done/altbestand/slice-"):
			imArchivSlices++
		default:
			t.Errorf("fremder Archiv-Eintrag: %s", e)
		}
	}
	if imArchivReviews != reviews || imArchivSlices != wellenlos {
		t.Errorf("Archiv: %d Slices / %d Reports, Vorschau nannte %d / %d", imArchivSlices, imArchivReviews, wellenlos, reviews)
	}

	if got := strings.Join(flacheMd(t, root), ","); got != "slice-102-c.md,slice-103-d.md,welle-10-eine-welle.md,welle-10-results.md" {
		t.Errorf("flach in done/ nach dem Lauf: %s", got)
	}
	for _, r := range []string{"2026-05-05-slice-100-r1.md", "2026-05-06-slice-101-r1.md"} {
		if _, err := os.Stat(filepath.Join(root, "docs", "reviews", r)); err == nil {
			t.Errorf("Review-Report %s liegt noch da", r)
		}
	}

	stub, err := os.ReadFile(filepath.Join(root, "docs", "plan", "planning", "done", "altbestand", "slice-100-a.md"))
	if err != nil {
		t.Fatal(err)
	}
	for _, w := range []string{"**Welle:** ohne Welle\n", "**Archiviert mit:** altbestand · **Geschlossen:** —", "done/altbestand/archiv.zip"} {
		if !strings.Contains(string(stub), w) {
			t.Errorf("Stub traegt %q nicht:\n%s", w, stub)
		}
	}
	if strings.Contains(string(stub), "\n##") {
		t.Errorf("Stub traegt eine Abschnittsueberschrift:\n%s", stub)
	}

	if want := "mv,mv,commit,rm,add,commit"; strings.Join(g.rufe, ",") != want {
		t.Errorf("git-Aufrufe = %v, want %s", g.rufe, want)
	}
	if len(g.commits) != 2 {
		t.Fatalf("%d Commits, want 2", len(g.commits))
	}
	for _, c := range g.commits {
		if !strings.Contains(c, "ADR-0041") {
			t.Errorf("Commit-Nachricht ohne Kennung: %q", c)
		}
	}
}

// TestArchiveWelleAltbestandNimmtDieUntergrenzeSperreWeg haelt (6): vor dem Lauf
// sperrt die Vorschau einer Welle mit [untergrenze], danach nicht mehr.
func TestArchiveWelleAltbestandNimmtDieUntergrenzeSperreWeg(t *testing.T) {
	root := altbestandBaum(t)
	var vorher, nachher, errb bytes.Buffer
	archiveWelleLauf(root, einCommit(t, root), "welle-10", true, "", indexAttrappe(t, root), &gitBewegend{root: root}, &vorher, &errb)
	if !strings.Contains(vorher.String(), "[untergrenze]") {
		t.Fatalf("Vorbedingung: ohne Sammel-Archiv fehlt [untergrenze]:\n%s", vorher.String())
	}

	var out bytes.Buffer
	if code := archiveWelleLauf(root, einCommit(t, root), "altbestand", false, "", indexAttrappe(t, root), &gitBewegend{root: root}, &out, &errb); code != 0 {
		t.Fatalf("Lauf Exit %d:\n%s%s", code, out.String(), errb.String())
	}
	archiveWelleLauf(root, einCommit(t, root), "welle-10", true, "", indexAttrappe(t, root), &gitBewegend{root: root}, &nachher, &errb)
	if strings.Contains(nachher.String(), "[untergrenze]") {
		t.Errorf("nach dem Sammel-Archiv steht [untergrenze] noch:\n%s", nachher.String())
	}
}

// TestArchiveWelleAltbestandZweiterLaufSperrtAnArchiviert haelt L2 (4) am STILLEN
// Pfad: vor dem zweiten Lauf liegt wieder ein wellenloser Slice flach, damit kein
// anderer Ausgang ('kein-slice') den Lauf ohnehin beendet. Gemessen wird, dass
// der zweite Lauf an 'archiviert' abbricht, nichts schreibt und kein zweites
// Archiv entsteht.
func TestArchiveWelleAltbestandZweiterLaufSperrtAnArchiviert(t *testing.T) {
	root := altbestandBaum(t)
	var out, errb bytes.Buffer
	if code := archiveWelleLauf(root, einCommit(t, root), "altbestand", false, "", indexAttrappe(t, root), &gitBewegend{root: root}, &out, &errb); code != 0 {
		t.Fatalf("erster Lauf Exit %d:\n%s%s", code, out.String(), errb.String())
	}
	schreibeDatei(t, root, doneRel+"slice-104-e.md", "# Slice slice-104: E\n\n**Welle:** ohne Welle\n")
	vorher := baumAbdruck(t, root)

	g := &gitBewegend{root: root}
	var zweiter bytes.Buffer
	code := archiveWelleLauf(root, einCommit(t, root), "altbestand", false, "", indexAttrappe(t, root), g, &zweiter, &errb)
	if code != 3 {
		t.Errorf("zweiter Lauf Exit %d, want 3", code)
	}
	if !strings.Contains(zweiter.String(), "[archiviert]") {
		t.Errorf("Sperre 'archiviert' fehlt:\n%s", zweiter.String())
	}
	if len(g.rufe) != 0 {
		t.Errorf("git-Operationen trotz Sperre: %v", g.rufe)
	}
	if baumAbdruck(t, root) != vorher {
		t.Error("der zweite Lauf hat den Baum veraendert")
	}
}

// TestArchiveWelleAltbestandSperrtImLaufBeiHaenger haelt L2 (5) und ADR-0041
// Festlegung 4 am schreibenden Lauf: ein bleibender Report verlinkt einen
// Review-Report, der verschwinden soll. Exit 3, nichts geschrieben.
func TestArchiveWelleAltbestandSperrtImLaufBeiHaenger(t *testing.T) {
	root := altbestandBaum(t)
	schreibeDatei(t, root, "docs/reviews/2026-09-02-slice-900-r1.md",
		"# Fremder Report\n\nSiehe [Vorrunde](2026-05-05-slice-100-r1.md).\n")
	vorher := baumAbdruck(t, root)

	g := &gitBewegend{root: root}
	var out, errb bytes.Buffer
	code := archiveWelleLauf(root, einCommit(t, root), "altbestand", false, "", indexAttrappe(t, root), g, &out, &errb)
	if code != 3 {
		t.Errorf("Exit %d, want 3:\n%s", code, out.String())
	}
	if !strings.Contains(out.String(), "[haenger]") {
		t.Errorf("Sperre 'haenger' fehlt:\n%s", out.String())
	}
	if len(g.rufe) != 0 {
		t.Errorf("git-Operationen trotz Sperre: %v", g.rufe)
	}
	if baumAbdruck(t, root) != vorher {
		t.Error("der gesperrte Lauf hat den Baum veraendert")
	}
}

// TestArchiveWelleAltbestandSperrtImLaufBeiPlanDatei haelt F1 am Lauf: eine
// Datei `altbestand*.md` in done/ beendet ihn mit Exit 3, ohne Schreibzugriff.
func TestArchiveWelleAltbestandSperrtImLaufBeiPlanDatei(t *testing.T) {
	root := altbestandBaum(t)
	schreibeDatei(t, root, doneRel+"altbestand-plan.md", "# Plan\n")
	vorher := baumAbdruck(t, root)

	g := &gitBewegend{root: root}
	var out, errb bytes.Buffer
	if code := archiveWelleLauf(root, einCommit(t, root), "altbestand", false, "", indexAttrappe(t, root), g, &out, &errb); code != 3 {
		t.Errorf("Exit %d, want 3:\n%s", code, out.String())
	}
	if !strings.Contains(out.String(), "[altbestand-plan]") || len(g.rufe) != 0 || baumAbdruck(t, root) != vorher {
		t.Errorf("Sperre fehlt oder der Lauf schrieb (rufe %v):\n%s", g.rufe, out.String())
	}
}

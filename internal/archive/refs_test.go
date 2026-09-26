package archive_test

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/pt9912/ai-harness-init/internal/archive"
)

func TestZaehlePraefixAnDerWortgrenze(t *testing.T) {
	faelle := []struct {
		inhalt string
		want   int
	}{
		{"[a](done/slice-100-a.md) und [b](../done/slice-100-a.md)", 2},
		{"done/slice-100-a.md am Zeilenanfang", 1},
		{"[x](../../../docs/plan/planning/done/slice-100-a.md)", 1},
		{"nicht-done/slice-100-a.md", 0},
		{"[c](done/slice-100-anders.md)", 0},
	}
	for _, f := range faelle {
		if got := archive.ZaehlePraefix(f.inhalt, "slice-100-a.md"); got != f.want {
			t.Errorf("ZaehlePraefix(%q) = %d, want %d", f.inhalt, got, f.want)
		}
	}
}

func TestZaehleGeschwisterUndAufsteigendSindDisjunkt(t *testing.T) {
	inhalt := "[a](slice-100-a.md) · [b](../slice-100-a.md) · [c](done/slice-100-a.md)"
	if got := archive.ZaehleGeschwister(inhalt, "slice-100-a.md"); got != 1 {
		t.Errorf("ZaehleGeschwister = %d, want 1", got)
	}
	if got := archive.ZaehleAufsteigend(inhalt, "slice-100-a.md"); got != 1 {
		t.Errorf("ZaehleAufsteigend = %d, want 1", got)
	}
}

// TestVerweisFundDreiFormenInIhremSuchraum: jede Form wird genau dort gezaehlt,
// wo ihr Link-Ziel die bewegte Datei ueberhaupt aufloest — die praefixlose aus
// den flach in done/ liegenden Dateien, die aufsteigende aus done/<welle-x>/,
// die Praefix-Form ueberall.
func TestVerweisFundDreiFormenInIhremSuchraum(t *testing.T) {
	root := t.TempDir()
	done := filepath.Join(root, "docs", "plan", "planning", "done")
	// docs/reviews steht fuer "ueberall, auch weit ausserhalb von done/" —
	// ADR-0070 Festlegung 2 haelt diesen Baum IM Suchraum des Nachzugs
	// (anders als docs/plan/adr, s. TestVerweisFundUndNachziehenUebergehenAcceptedADR).
	schreibe(t, filepath.Join(root, "docs", "reviews", "2026-09-01-x.md"),
		"Siehe [slice-100](../planning/done/slice-100-a.md).\n")
	schreibe(t, filepath.Join(done, "welle-10-results.md"),
		"Geliefert: [slice-100](slice-100-a.md).\n")
	schreibe(t, filepath.Join(done, "welle-09", "slice-090-x.md"),
		"Folge-Slice: [slice-100](../slice-100-a.md).\n")
	schreibe(t, filepath.Join(root, "docs", "plan", "planning", "next", "slice-900-y.md"),
		"Geschwister im eigenen Verzeichnis: [x](slice-100-a.md).\n")
	// Die zwei relativen Formen tragen zusaetzlich eine Dateityp-Achse: sie sind
	// Markdown-Link-Ziele und loesen ausserhalb einer Markdown-Datei gegen nichts
	// auf. Beide Nicht-Markdown-Dateien liegen IM Suchraum ihrer Form und duerfen
	// trotzdem keinen Treffer ergeben.
	schreibe(t, filepath.Join(done, "notiz.txt"),
		"Kein Markdown: [x](slice-100-a.md).\n")
	schreibe(t, filepath.Join(done, "welle-09", "notiz.txt"),
		"Kein Markdown: [x](../slice-100-a.md).\n")

	funde, err := archive.VerweisFund(root, []string{
		"docs/reviews/2026-09-01-x.md",
		"docs/plan/planning/done/welle-10-results.md",
		"docs/plan/planning/done/welle-09/slice-090-x.md",
		"docs/plan/planning/next/slice-900-y.md",
		"docs/plan/planning/done/notiz.txt",
		"docs/plan/planning/done/welle-09/notiz.txt",
	}, []string{"slice-100-a.md"})
	if err != nil {
		t.Fatal(err)
	}
	got := map[string]archive.Fund{}
	for _, f := range funde {
		got[f.Datei] = f
	}
	if f := got["docs/reviews/2026-09-01-x.md"]; f.Praefix != 1 || f.Summe() != 1 {
		t.Errorf("Review-Report: %+v, want genau 1 Praefix-Treffer", f)
	}
	if f := got["docs/plan/planning/done/welle-10-results.md"]; f.Geschwister != 1 || f.Summe() != 1 {
		t.Errorf("Ergebnisnotiz: %+v, want genau 1 geschwister-relativen Treffer", f)
	}
	if f := got["docs/plan/planning/done/welle-09/slice-090-x.md"]; f.Aufsteigend != 1 || f.Summe() != 1 {
		t.Errorf("Stub der Vorwelle: %+v, want genau 1 aufsteigenden Treffer", f)
	}
	if _, drin := got["docs/plan/planning/next/slice-900-y.md"]; drin {
		t.Error("praefixloses Ziel ausserhalb von done/ gezaehlt — es loest gegen next/ auf, nicht gegen done/")
	}
	for _, ohneMd := range []string{
		"docs/plan/planning/done/notiz.txt",
		"docs/plan/planning/done/welle-09/notiz.txt",
	} {
		if _, drin := got[ohneMd]; drin {
			t.Errorf("relative Link-Form in %s gezaehlt — ausserhalb einer Markdown-Datei loest sie gegen nichts auf", ohneMd)
		}
	}
	if len(funde) != 3 {
		t.Fatalf("VerweisFund = %d Dateien, want 3", len(funde))
	}
}

// TestVerweisFundPraefixAusNichtMarkdownDatei: die Praefix-Form ankert am
// Literal "done/" und gilt in jedem Dateityp — der Nachzug haengt sie ohne
// Endungs-Filter um und stagt die getroffene Datei in den Inhalts-Commit.
// Zwei Dateien des Bestands stehen fuer die Klasse:
// `Dockerfile`, aus dem `make test`, `make lint` und `make build` ihre Stages
// ziehen, und eine bats-Datei. Nennt die Vorschau sie nicht, ist ihr
// Blast-Radius kleiner als das, was der Lauf anfasst.
// Gegenbeispiel: test/mutations/238-archive-welle-go-suchraum-dateityp.sh.
// Die Fixture-Namen sind ERFUNDEN, obwohl der Bestand echte traegt. Ein echter
// Name in dieser Datei stuende im Blast-Radius des naechsten Laufs, und der
// Nachzug haengte ihn um — der Fall risse sich damit selbst um.
func TestVerweisFundPraefixAusNichtMarkdownDatei(t *testing.T) {
	root := t.TempDir()
	schreibe(t, filepath.Join(root, "Dockerfile"),
		"# Begruendung: docs/plan/planning/done/slice-900-kompilat-cache.md\n")
	schreibe(t, filepath.Join(root, "test", "full-smoke-ausgang.bats"),
		"# siehe done/slice-900-kompilat-cache.md\n")

	funde, err := archive.VerweisFund(root,
		[]string{"Dockerfile", "test/full-smoke-ausgang.bats"},
		[]string{"slice-900-kompilat-cache.md"})
	if err != nil {
		t.Fatal(err)
	}
	if len(funde) != 2 {
		t.Fatalf("VerweisFund = %v, want beide Dateien ohne .md-Endung", funde)
	}
	for _, f := range funde {
		if f.Praefix != 1 || f.Summe() != 1 {
			t.Errorf("%+v, want genau 1 Praefix-Treffer", f)
		}
	}
}

// TestVerweisFundUebergehtDenEigenenUmzugsgegenstand: die praefixlose Form zaehlt
// nicht in einer Datei, die dieser Lauf selbst mitnimmt. Zwei Mitglieder
// derselben Welle, die einander geschwister-relativ verlinken, wandern gemeinsam
// nach done/<welle-id>/; ihre Links bleiben gueltig, und der Nachzug fasst sie
// nicht an. Wer sie zaehlt, meldet einen zu grossen Blast-Radius.
func TestVerweisFundUebergehtDenEigenenUmzugsgegenstand(t *testing.T) {
	root := t.TempDir()
	done := filepath.Join(root, "docs", "plan", "planning", "done")
	schreibe(t, filepath.Join(done, "slice-100-a.md"),
		"Nachbar: [slice-101](slice-101-b.md).\n")
	schreibe(t, filepath.Join(done, "slice-101-b.md"),
		"Vorlaeufer: [slice-100](slice-100-a.md).\n")
	schreibe(t, filepath.Join(done, "welle-10-results.md"),
		"Geliefert: [slice-100](slice-100-a.md) und [slice-101](slice-101-b.md).\n")

	funde, err := archive.VerweisFund(root, []string{
		"docs/plan/planning/done/slice-100-a.md",
		"docs/plan/planning/done/slice-101-b.md",
		"docs/plan/planning/done/welle-10-results.md",
	}, []string{"slice-100-a.md", "slice-101-b.md"})
	if err != nil {
		t.Fatal(err)
	}
	if len(funde) != 1 || funde[0].Datei != "docs/plan/planning/done/welle-10-results.md" {
		t.Fatalf("VerweisFund = %+v, want nur die bleibende Ergebnisnotiz", funde)
	}
	if funde[0].Geschwister != 2 {
		t.Fatalf("Ergebnisnotiz = %+v, want 2 geschwister-relative Fundstellen", funde[0])
	}
}

// TestNachziehenSchreibtGenauDortWoVerweisFundZaehlt: der zaehlende und der
// schreibende Leser fragen dieselbe Suchraum-Regel. Waeren es zwei Fassungen,
// saegte die Vorschau einen anderen Blast-Radius, als der Lauf anfasst — und der
// Aufrufer haette eine Aussage, auf die er sich nicht verlassen kann.
func TestNachziehenSchreibtGenauDortWoVerweisFundZaehlt(t *testing.T) {
	baum := func() (string, []string) {
		root := t.TempDir()
		done := filepath.Join(root, "docs", "plan", "planning", "done")
		schreibe(t, filepath.Join(root, "docs", "reviews", "2026-09-01-x.md"),
			"Siehe [slice-100](../planning/done/slice-100-a.md).\n")
		schreibe(t, filepath.Join(done, "welle-10-results.md"),
			"Geliefert: [slice-100](slice-100-a.md).\n")
		schreibe(t, filepath.Join(done, "welle-09", "slice-090-x.md"),
			"Folge-Slice: [slice-100](../slice-100-a.md).\n")
		schreibe(t, filepath.Join(root, "docs", "plan", "planning", "next", "slice-900-y.md"),
			"Geschwister im eigenen Verzeichnis: [x](slice-100-a.md).\n")
		schreibe(t, filepath.Join(done, "slice-100-a.md"), "# Slice slice-100: A\n")
		return root, []string{
			"docs/reviews/2026-09-01-x.md",
			"docs/plan/planning/done/welle-10-results.md",
			"docs/plan/planning/done/welle-09/slice-090-x.md",
			"docs/plan/planning/next/slice-900-y.md",
			"docs/plan/planning/done/slice-100-a.md",
		}
	}

	root, dateien := baum()
	gezaehlt, err := archive.VerweisFund(root, dateien, []string{"slice-100-a.md"})
	if err != nil {
		t.Fatal(err)
	}
	geschrieben, err := archive.Nachziehen(root, dateien, []string{"slice-100-a.md"}, "welle-10")
	if err != nil {
		t.Fatal(err)
	}
	if len(gezaehlt) != len(geschrieben) {
		t.Fatalf("VerweisFund = %+v, Nachziehen = %+v — verschiedene Suchraeume", gezaehlt, geschrieben)
	}
	for i := range gezaehlt {
		if gezaehlt[i] != geschrieben[i] {
			t.Errorf("Datei %d: gezaehlt %+v, geschrieben %+v", i, gezaehlt[i], geschrieben[i])
		}
	}

	inhalte := map[string]string{
		"docs/reviews/2026-09-01-x.md":                    "](../planning/done/welle-10/slice-100-a.md)",
		"docs/plan/planning/done/welle-10-results.md":     "](welle-10/slice-100-a.md)",
		"docs/plan/planning/done/welle-09/slice-090-x.md": "](../welle-10/slice-100-a.md)",
		"docs/plan/planning/next/slice-900-y.md":          "](slice-100-a.md)",
	}
	for datei, want := range inhalte {
		b, rerr := os.ReadFile(filepath.Join(root, filepath.FromSlash(datei)))
		if rerr != nil {
			t.Fatal(rerr)
		}
		if !strings.Contains(string(b), want) {
			t.Errorf("%s traegt %q nicht:\n%s", datei, want, b)
		}
	}
}

// TestVerweisFundUndNachziehenUebergehenAcceptedADR ist ADR-0042 Festlegung 2:
// eine Accepted-ADR unter docs/plan/adr traegt nach dem Nachzug denselben
// Inhalt, obwohl sie denselben Praefix-Verweis traegt wie ein gleichzeitig
// vorhandener Review-Report, der weiterhin gezaehlt und umgehaengt wird
// (ADR-0070 Festlegung 2: docs/reviews/** bleibt drin).
func TestVerweisFundUndNachziehenUebergehenAcceptedADR(t *testing.T) {
	root := t.TempDir()
	adr := "docs/plan/adr/0033-x.md"
	report := "docs/reviews/2026-09-01-slice-100-r1.md"
	schreibe(t, filepath.Join(root, filepath.FromSlash(adr)),
		"Siehe [slice-100](done/slice-100-a.md).\n")
	schreibe(t, filepath.Join(root, filepath.FromSlash(report)),
		"Siehe [slice-100](done/slice-100-a.md).\n")

	dateien := []string{adr, report}
	funde, err := archive.VerweisFund(root, dateien, []string{"slice-100-a.md"})
	if err != nil {
		t.Fatal(err)
	}
	got := map[string]archive.Fund{}
	for _, f := range funde {
		got[f.Datei] = f
	}
	if f, drin := got[adr]; drin {
		t.Errorf("VerweisFund zaehlt in der ADR: %+v, want keinen Fund", f)
	}
	if f := got[report]; f.Praefix != 1 {
		t.Errorf("VerweisFund uebergeht den Review-Report: %+v, want genau 1 Praefix-Treffer", f)
	}

	geschrieben, err := archive.Nachziehen(root, dateien, []string{"slice-100-a.md"}, "welle-10")
	if err != nil {
		t.Fatal(err)
	}
	for _, f := range geschrieben {
		if f.Datei == adr {
			t.Fatalf("Nachziehen schreibt in die ADR: %+v", f)
		}
	}

	adrInhalt, err := os.ReadFile(filepath.Join(root, filepath.FromSlash(adr)))
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(adrInhalt), "](done/slice-100-a.md)") {
		t.Fatalf("ADR-Inhalt veraendert: %s", adrInhalt)
	}
	reportInhalt, err := os.ReadFile(filepath.Join(root, filepath.FromSlash(report)))
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(reportInhalt), "](done/welle-10/slice-100-a.md)") {
		t.Fatalf("Review-Report nicht nachgezogen: %s", reportInhalt)
	}
}

// bt setzt in den Fixtures unten das Zeichen "§" zu einem Backtick um — ein
// Raw-String kann selbst keinen tragen.
func bt(s string) string { return strings.NewReplacer("§", "`").Replace(s) }

// reportLinks und reportRest bilden EINE Datei unter docs/reviews/: reportLinks
// traegt vier Links auf die bewegte Datei (einen mit Anker, zwei davon neben
// einem Link auf eine fremde Datei in einer Zeile) — %[1]s ist das Segment, das
// der Nachzug vor den Dateinamen setzt —, reportRest die vier Nicht-Link-Formen:
// reiner Pfad-Span, Operand in einem Kommando-Span, Pfad im Code-Block, Pfad im
// Fliesstext.
const (
	reportLinks = "Link: [a](../planning/done/%[1]sslice-100-a.md) und [x](../planning/done/%[1]sslice-100-a.md#ziel).\n" +
		"Drei in einer Zeile: [a](../planning/done/%[1]sslice-100-a.md) [f](../planning/done/slice-999-fremd.md) [b](../planning/done/%[1]sslice-100-a.md)\n"
	reportRest = "Span: §done/slice-100-a.md§\n" +
		"Span voll: §docs/plan/planning/done/slice-100-a.md§\n" +
		"Operand: §git show HEAD:docs/plan/planning/done/slice-100-a.md§\n" +
		"Fliesstext: siehe docs/plan/planning/done/slice-100-a.md im Bericht.\n" +
		"§§§sh\ncat docs/plan/planning/done/slice-100-a.md\n§§§\n"
)

func reportBaum(t *testing.T) (root string, dateien []string) {
	t.Helper()
	root = t.TempDir()
	schreibe(t, filepath.Join(root, "docs", "reviews", "2026-09-01-x.md"),
		bt(fmt.Sprintf(reportLinks, "")+reportRest))
	schreibe(t, filepath.Join(root, "docs", "plan", "planning", "done", "slice-100-a.md"), "# Slice slice-100: A\n")
	return root, []string{
		"docs/reviews/2026-09-01-x.md",
		"docs/plan/planning/done/slice-100-a.md",
	}
}

// TestNachziehenUnterReviewsSchreibtNurDieLinkForm ist ADR-0070 Fitness-Zeile 1:
// in einer Datei unter docs/reviews/ sind alle Link-Ziele nachgezogen, und der
// reine Pfad-Span, der Operand, der Code-Block und der Fliesstext sind Byte fuer
// Byte gleich. Die Zaehl-Seite (VerweisFund, die Vorschau) nennt dieselbe Zahl,
// die die Ersetz-Seite schreibt.
//
// Gegenbeispiele: test/mutations/467-archive-welle-go-reports-verlieren-die-form-regel.sh
// (die Regel entfaellt, jede Form ist umgeschrieben),
// 468-archive-welle-go-reports-verlieren-den-link-nachzug.sh (die Links bleiben
// auf dem alten Ort), 470-archive-welle-go-zaehl-seite-laeuft-auseinander.sh.
func TestNachziehenUnterReviewsSchreibtNurDieLinkForm(t *testing.T) {
	root, dateien := reportBaum(t)
	gezaehlt, err := archive.VerweisFund(root, dateien, []string{"slice-100-a.md"})
	if err != nil {
		t.Fatal(err)
	}
	geschrieben, err := archive.Nachziehen(root, dateien, []string{"slice-100-a.md"}, "welle-10")
	if err != nil {
		t.Fatal(err)
	}

	// Vier Links auf die bewegte Datei stehen in der Datei; der fremde nicht.
	want := []archive.Fund{{Datei: "docs/reviews/2026-09-01-x.md", Praefix: 4}}
	if fmt.Sprint(gezaehlt) != fmt.Sprint(want) {
		t.Errorf("VerweisFund = %+v, want %+v", gezaehlt, want)
	}
	if fmt.Sprint(geschrieben) != fmt.Sprint(gezaehlt) {
		t.Errorf("Nachziehen = %+v, VerweisFund = %+v — Zaehl- und Ersetz-Seite laufen auseinander", geschrieben, gezaehlt)
	}

	b, err := os.ReadFile(filepath.Join(root, "docs", "reviews", "2026-09-01-x.md"))
	if err != nil {
		t.Fatal(err)
	}
	wantInhalt := bt(fmt.Sprintf(reportLinks, "welle-10/") + reportRest)
	if string(b) != wantInhalt {
		t.Errorf("Report nach dem Nachzug:\n%s\nwant:\n%s", b, wantInhalt)
	}
}

// TestNachziehenUnterReviewsSchreibtEineDateiOhneLinkNicht: eine Datei unter
// docs/reviews/, die die Adresse nur als Span, Operand, Block und Fliesstext
// traegt, ist kein Fund und wird nicht angefasst — auch ihr Zeitstempel bleibt.
func TestNachziehenUnterReviewsSchreibtEineDateiOhneLinkNicht(t *testing.T) {
	root := t.TempDir()
	rel := "docs/reviews/2026-09-02-y.md"
	p := filepath.Join(root, filepath.FromSlash(rel))
	schreibe(t, p, bt(reportRest))
	alt := time.Date(2001, 1, 2, 3, 4, 5, 0, time.UTC)
	if err := os.Chtimes(p, alt, alt); err != nil {
		t.Fatal(err)
	}

	funde, err := archive.VerweisFund(root, []string{rel}, []string{"slice-100-a.md"})
	if err != nil {
		t.Fatal(err)
	}
	geschrieben, err := archive.Nachziehen(root, []string{rel}, []string{"slice-100-a.md"}, "welle-10")
	if err != nil {
		t.Fatal(err)
	}
	if len(funde) != 0 || len(geschrieben) != 0 {
		t.Errorf("VerweisFund = %+v, Nachziehen = %+v, want beide leer", funde, geschrieben)
	}
	st, err := os.Stat(p)
	if err != nil {
		t.Fatal(err)
	}
	if !st.ModTime().Equal(alt) {
		t.Errorf("Datei ohne Link-Treffer angefasst: ModTime %v, want %v", st.ModTime(), alt)
	}
}

// TestNachziehenUnterReviewsErsetztLinkSyntaxImCodeSpanMit ist ADR-0070
// Fitness-Zeile 2, die Span-Haelfte der Grenze: die Regel liest kein Markdown,
// Link-Syntax als Zitat in einem Code-Span steht hinter "](" und wird ersetzt.
// Faellt der Test, weil ein Traeger eine Kontext-Erkennung bekam, ist das
// Re-Evaluierungs-Trigger 6 der ADR — Festlegung 1 ist dann per Folge-ADR zu
// aendern, der Fall nicht stillschweigend umzudrehen. Ein Link mit Titel und die
// Spitzklammer-Form enden nicht unmittelbar an ")" oder "#" und bleiben stehen.
func TestNachziehenUnterReviewsErsetztLinkSyntaxImCodeSpanMit(t *testing.T) {
	root := t.TempDir()
	rel := "docs/reviews/2026-09-03-z.md"
	schreibe(t, filepath.Join(root, filepath.FromSlash(rel)), bt(
		"Zitat: §[a](../planning/done/slice-100-a.md)§\n"+
			"Titel: [t](../planning/done/slice-100-a.md \"titel\")\n"+
			"Spitze: [s](<../planning/done/slice-100-a.md>)\n"))

	if _, err := archive.Nachziehen(root, []string{rel}, []string{"slice-100-a.md"}, "welle-10"); err != nil {
		t.Fatal(err)
	}
	b, err := os.ReadFile(filepath.Join(root, filepath.FromSlash(rel)))
	if err != nil {
		t.Fatal(err)
	}
	want := bt("Zitat: §[a](../planning/done/welle-10/slice-100-a.md)§\n" +
		"Titel: [t](../planning/done/slice-100-a.md \"titel\")\n" +
		"Spitze: [s](<../planning/done/slice-100-a.md>)\n")
	if string(b) != want {
		t.Errorf("Report nach dem Nachzug:\n%s\nwant:\n%s", b, want)
	}
}

// TestNachziehenInDoneErsetztJedeForm ist ADR-0070 Fitness-Zeile 5: in einer
// Datei unter docs/plan/planning/done/ sind Link, reiner Pfad-Span und Operand
// weiter nachgezogen — die Form-Regel gilt nur fuer docs/reviews/.
// Gegenbeispiel: test/mutations/469-archive-welle-go-form-regel-greift-in-done.sh.
func TestNachziehenInDoneErsetztJedeForm(t *testing.T) {
	root := t.TempDir()
	rel := "docs/plan/planning/done/welle-09-results.md"
	schreibe(t, filepath.Join(root, filepath.FromSlash(rel)), bt(
		"Link: [a](../done/slice-100-a.md)\n"+
			"Span: §docs/plan/planning/done/slice-100-a.md§\n"+
			"Operand: §git show HEAD:docs/plan/planning/done/slice-100-a.md§\n"))

	if _, err := archive.Nachziehen(root, []string{rel}, []string{"slice-100-a.md"}, "welle-10"); err != nil {
		t.Fatal(err)
	}
	b, err := os.ReadFile(filepath.Join(root, filepath.FromSlash(rel)))
	if err != nil {
		t.Fatal(err)
	}
	want := bt("Link: [a](../done/welle-10/slice-100-a.md)\n" +
		"Span: §docs/plan/planning/done/welle-10/slice-100-a.md§\n" +
		"Operand: §git show HEAD:docs/plan/planning/done/welle-10/slice-100-a.md§\n")
	if string(b) != want {
		t.Errorf("Ergebnisnotiz nach dem Nachzug:\n%s\nwant:\n%s", b, want)
	}
}

// TestPraefixLinkAnDerWortgrenze: die Link-Fassung hat dieselbe Wortgrenze wie
// ZaehlePraefix und endet an ")" oder "#"; ein zweiter Lauf trifft das
// nachgezogene Ziel nicht mehr.
func TestPraefixLinkAnDerWortgrenze(t *testing.T) {
	faelle := []struct {
		inhalt string
		want   int
	}{
		{"[a](done/slice-100-a.md)", 1},
		{"[a](../../planning/done/slice-100-a.md#x)", 1},
		{"[a](sibling-done/slice-100-a.md)", 0},
		{"[a](done/slice-100-anders.md)", 0},
		{"[a](done/slice-100-a.md.bak)", 0},
		{"done/slice-100-a.md ohne Link-Klammer", 0},
	}
	for _, f := range faelle {
		if got := archive.ZaehlePraefixLink(f.inhalt, "slice-100-a.md"); got != f.want {
			t.Errorf("ZaehlePraefixLink(%q) = %d, want %d", f.inhalt, got, f.want)
		}
	}
	neu, n := archive.ErsetzePraefixLink("[a](../done/slice-100-a.md)", "slice-100-a.md", "welle-10")
	if n != 1 || neu != "[a](../done/welle-10/slice-100-a.md)" {
		t.Fatalf("ErsetzePraefixLink = %q, %d", neu, n)
	}
	if _, n2 := archive.ErsetzePraefixLink(neu, "slice-100-a.md", "welle-11"); n2 != 0 {
		t.Errorf("zweiter Lauf ersetzt das nachgezogene Ziel erneut (%d)", n2)
	}
}

// TestNachziehenUnterReviewsUeberquertKeineZeilengrenze ist die Zeilen-Haelfte der
// Grenze von praefixLinkRE: ein "](" am Zeilenende und eine Adresse, die erst in
// einer spaeteren Zeile beginnt (mitten in der Zeile und am Zeilenanfang), sind
// kein Link-Ziel und bleiben Byte fuer Byte; der eine echte Link am Ende der
// Datei ist nachgezogen, die Menge der Treffer ist also nicht leer.
// Gegenbeispiel: test/mutations/472-archive-welle-go-link-regel-ueberquert-die-zeilengrenze.sh.
func TestNachziehenUnterReviewsUeberquertKeineZeilengrenze(t *testing.T) {
	root := t.TempDir()
	rel := "docs/reviews/2026-09-04-w.md"
	umbruch := "Umbruch: [a](\n" +
		"Pfad docs/plan/planning/done/slice-100-a.md) im Fliesstext.\n" +
		"Zeilenanfang: [b](\n" +
		"done/slice-100-a.md) am Zeilenanfang.\n"
	link := "Link: [c](../planning/done/%sslice-100-a.md)\n"
	schreibe(t, filepath.Join(root, filepath.FromSlash(rel)), umbruch+fmt.Sprintf(link, ""))

	if n := archive.ZaehlePraefixLink(umbruch+fmt.Sprintf(link, ""), "slice-100-a.md"); n != 1 {
		t.Errorf("ZaehlePraefixLink = %d, want 1 (nur der Link in einer Zeile)", n)
	}
	geschrieben, err := archive.Nachziehen(root, []string{rel}, []string{"slice-100-a.md"}, "welle-10")
	if err != nil {
		t.Fatal(err)
	}
	if want := []archive.Fund{{Datei: rel, Praefix: 1}}; fmt.Sprint(geschrieben) != fmt.Sprint(want) {
		t.Errorf("Nachziehen = %+v, want %+v", geschrieben, want)
	}
	b, err := os.ReadFile(filepath.Join(root, filepath.FromSlash(rel)))
	if err != nil {
		t.Fatal(err)
	}
	if want := umbruch + fmt.Sprintf(link, "welle-10/"); string(b) != want {
		t.Errorf("Report nach dem Nachzug:\n%s\nwant:\n%s", b, want)
	}
}

// TestNachziehenUnterReviewsGiltNurFuerDasVerzeichnisNichtFuerSeinenPraefix: die
// Link-Form-Regel bindet an das Verzeichnis docs/reviews/, nicht an einen Pfad,
// der nur mit "docs/reviews" beginnt. Ein Geschwister-Verzeichnis dieses
// Praefixes bekommt jede Form, docs/reviews/ nur den Link.
// Gegenbeispiel: test/mutations/473-archive-welle-go-report-baum-endet-nicht-am-verzeichnis.sh.
func TestNachziehenUnterReviewsGiltNurFuerDasVerzeichnisNichtFuerSeinenPraefix(t *testing.T) {
	root := t.TempDir()
	inhalt := bt("Link: [a](../planning/done/slice-100-a.md)\n" +
		"Span: §docs/plan/planning/done/slice-100-a.md§\n")
	report := "docs/reviews/2026-09-05-r.md"
	nachbar := "docs/reviews-alt/2026-09-05-n.md"
	schreibe(t, filepath.Join(root, filepath.FromSlash(report)), inhalt)
	schreibe(t, filepath.Join(root, filepath.FromSlash(nachbar)), inhalt)

	if _, err := archive.Nachziehen(root, []string{report, nachbar}, []string{"slice-100-a.md"}, "welle-10"); err != nil {
		t.Fatal(err)
	}
	want := map[string]string{
		report: bt("Link: [a](../planning/done/welle-10/slice-100-a.md)\n" +
			"Span: §docs/plan/planning/done/slice-100-a.md§\n"),
		nachbar: bt("Link: [a](../planning/done/welle-10/slice-100-a.md)\n" +
			"Span: §docs/plan/planning/done/welle-10/slice-100-a.md§\n"),
	}
	for rel, w := range want {
		b, err := os.ReadFile(filepath.Join(root, filepath.FromSlash(rel)))
		if err != nil {
			t.Fatal(err)
		}
		if string(b) != w {
			t.Errorf("%s nach dem Nachzug:\n%s\nwant:\n%s", rel, b, w)
		}
	}
}

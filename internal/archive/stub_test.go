package archive_test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/archive"
)

// pruefTag ist der <tag> des synthetischen Baseline-Baums der Tests.
const pruefTag = "v9.99.0"

// vorlagenMarker steht NUR in den Prueftext-Vorlagen und in keiner echten. Ein
// Stub, der ihn traegt, kann seine Form nicht aus dem Code haben.
const vorlagenMarker = "PRUEFBAUM-MARKER"

const vorlageSlice = `# slice-<Kennung> — <Titel>

> **Template-Hinweis.** ` + vorlagenMarker + ` — dieser Absatz faellt beim Kuerzen weg.

Regeln dieses Artefakts: irgendwo im Regelwerk.

## Eine Abschnittsueberschrift, die der Stub nicht traegt

<!-- BEDIENHINWEIS

mehrzeilig, mit Leerzeile darin.
-->

> **ARCHIVIERT** — Volltext:
> ` + "`unzip -p done/<welle-id>/archiv.zip <pfad-im-archiv>`" + `

**Welle:** <welle-id | ohne Welle>
**Archiviert mit:** <welle-id> · **Geschlossen:** <JJJJ-MM-TT>
**Hervorgegangen:** <BEO-*, ADR-*, Folge-Slice — oder ` + "`— keine —`" + `>
`

const vorlageWelle = `# <welle-id> — <Titel>

> **Template-Hinweis.** ` + vorlagenMarker + ` — dieser Absatz faellt beim Kuerzen weg.

## Eine Abschnittsueberschrift, die der Stub nicht traegt

> **ARCHIVIERT** — Volltext:
> ` + "`unzip -p done/<welle-id>/archiv.zip <pfad-im-archiv>`" + `

**Geschlossen:** <JJJJ-MM-TT> · **Ergebnisnotiz:** <welle-id>-results.md
**Archivierte Vorgänge:** <N Slices, M Reviews>
`

// vorlagenBaum legt den synthetischen vendored Baum an und liefert sein
// templates-Verzeichnis.
//
// Die zwei Vorlagen sind ABSICHTLICH nicht die echten: sie tragen einen Marker,
// den keine echte traegt. Ein Stub, der ihn abdruckt, hat seine Form aus der
// Datei gelesen — das ist die Eigenschaft, die ADR-0033 Festlegung 3 verlangt.
// Die Deckung gegen die ECHTEN Vorlagen liegt nicht hier: `.dockerignore` haelt
// .harness aus dem Build-Kontext der Go-Test-Stufe, und die Platzhalter-Kopplung
// traegt test/archiv-stub-vorlagen.bats.
func vorlagenBaum(t *testing.T, root string) string {
	t.Helper()
	dir := filepath.Join(root, ".harness", "baseline", pruefTag, "templates", "docs", "plan", "planning")
	schreibe(t, filepath.Join(dir, "archiv-stub-slice.template.md"), vorlageSlice)
	schreibe(t, filepath.Join(dir, "archiv-stub-welle.template.md"), vorlageWelle)
	return dir
}

// TestVorlagenVerzeichnisEntdecktDenEinenTag: der <tag> wird gefunden, nicht
// geraten — und zwei Tags sind ein Fehler, kein Rateversuch.
func TestVorlagenVerzeichnisEntdecktDenEinenTag(t *testing.T) {
	root := t.TempDir()
	vorlagenBaum(t, root)
	dir, err := archive.VorlagenVerzeichnis(root)
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(filepath.ToSlash(dir), "/"+pruefTag+"/templates/docs/plan/planning") {
		t.Fatalf("VorlagenVerzeichnis = %q", dir)
	}
	if err := os.MkdirAll(filepath.Join(root, ".harness", "baseline", "v9.99.1"), 0o755); err != nil {
		t.Fatal(err)
	}
	if _, err := archive.VorlagenVerzeichnis(root); err == nil {
		t.Fatal("zwei <tag>-Verzeichnisse: want Fehler, got nil")
	}
}

// TestAusVorlageFaelltOhneVorlageAus ist das rote Gegenbeispiel zu ADR-0033
// Festlegung 3: fehlt die Vorlage, faellt der Aufruf aus, statt eine Form zu
// erfinden.
func TestAusVorlageFaelltOhneVorlageAus(t *testing.T) {
	root := t.TempDir()
	dir := vorlagenBaum(t, root)
	weg := filepath.Join(dir, "archiv-stub-slice.template.md")
	if err := os.Remove(weg); err != nil {
		t.Fatal(err)
	}
	text, err := archive.AusVorlage(weg, nil)
	if err == nil {
		t.Fatalf("ohne Vorlage kein Fehler, stattdessen: %q", text)
	}
	if !strings.Contains(err.Error(), "Vorlage fehlt") {
		t.Fatalf("Fehlertext nennt die fehlende Vorlage nicht: %v", err)
	}
}

// TestKuerzeLaesstNurH1ZeigerUndFeldblock: die Kuerzung nimmt genau die drei
// Teile mit, die die Ziel-Form ausmachen — H1, Archiv-Zeiger, letzter Absatz.
// Alles dazwischen schreibt an den Kopierenden und faellt weg.
func TestKuerzeLaesstNurH1ZeigerUndFeldblock(t *testing.T) {
	got := archive.Kuerze(vorlageSlice)
	want := "# slice-<Kennung> — <Titel>\n" +
		"\n" +
		"> **ARCHIVIERT** — Volltext:\n" +
		"> `unzip -p done/<welle-id>/archiv.zip <pfad-im-archiv>`\n" +
		"\n" +
		"**Welle:** <welle-id | ohne Welle>\n" +
		"**Archiviert mit:** <welle-id> · **Geschlossen:** <JJJJ-MM-TT>\n" +
		"**Hervorgegangen:** <BEO-*, ADR-*, Folge-Slice — oder `— keine —`>\n"
	if got != want {
		t.Fatalf("Kuerze =\n%q\nwant\n%q", got, want)
	}
}

// TestFormOKMeldetStehengebliebeneUeberschrift haelt die tragende Haelfte der
// Form-Pruefung. Ein Stub mit Zeiger UND vollem Text waere die Archivierung, die
// nicht stattfand — die Ueberschrift ist das Merkmal, an dem das ablesbar ist.
// Gegenbeispiel: test/mutations/239-archive-welle-go-stub-ueberschrift.sh.
func TestFormOKMeldetStehengebliebeneUeberschrift(t *testing.T) {
	gekuerzt := archive.Kuerze(vorlageSlice)
	if err := archive.FormOK(gekuerzt); err != nil {
		t.Fatalf("gekuerzte Vorlage soll die Form erfuellen: %v", err)
	}
	mitUeberschrift := gekuerzt + "\n## Ziel\n\nvoller Text\n"
	err := archive.FormOK(mitUeberschrift)
	if err == nil {
		t.Fatal("Abschnittsueberschrift im Stub: want Fehler, got nil")
	}
	if !strings.Contains(err.Error(), "Abschnittsueberschriften") {
		t.Fatalf("Fehlertext nennt die Ueberschrift nicht: %v", err)
	}
	if err := archive.FormOK("# slice-100 — T\n\n**Welle:** welle-10\n"); err == nil {
		t.Fatal("Stub ohne Archiv-Zeiger: want Fehler, got nil")
	}
}

// TestTitelVonLaesstDenNummernRestStehen misst die vier getroffenen H1-Formen UND
// die Grenze, die der Funktionskopf benennt: `# Slice 190: T` traegt das Wort ohne
// `slice-`-Praefix, die dritte Ersetzung greift dort nicht, und der Rest `190:`
// bleibt stehen. Der Fall steht hier, damit die Zusage nicht weiter reicht als
// der Code.
func TestTitelVonLaesstDenNummernRestStehen(t *testing.T) {
	faelle := []struct{ kopf, want string }{
		{"# Slice slice-190: Der Titel", "Der Titel"},
		{"# slice-190 — Der Titel", "Der Titel"},
		{"# Welle welle-87: Der Titel", "Der Titel"},
		{"# welle-87 — Der Titel", "Der Titel"},
		{"# slice-001a - Der Titel", "Der Titel"},
		{"# Ganz ohne Kennung", "Ganz ohne Kennung"},
		{"# Slice 190: Der Titel", "190: Der Titel"},
	}
	for _, f := range faelle {
		if got := archive.TitelVon(f.kopf); got != f.want {
			t.Errorf("TitelVon(%q) = %q, want %q", f.kopf, got, f.want)
		}
	}
}

// TestGeschlossenDatumNimmtDieLetzteRollenZeile: eine Slice-Datei kann mehrere
// `**Rolle:** … **Datum:**`-Zeilen tragen (Review-Runden); der Abschluss ist die
// letzte. Ohne eine solche Zeile gilt der Ersatz.
func TestGeschlossenDatumNimmtDieLetzteRollenZeile(t *testing.T) {
	inhalt := "**Rolle:** Reviewer · **Datum:** 2026-01-02\n\ntext\n\n**Rolle:** Planner · **Datum:** 2026-03-04\n"
	if got := archive.GeschlossenDatum(inhalt, "—"); got != "2026-03-04" {
		t.Errorf("GeschlossenDatum = %q, want 2026-03-04", got)
	}
	if got := archive.GeschlossenDatum("ohne Zeile\n", "2026-09-09"); got != "2026-09-09" {
		t.Errorf("GeschlossenDatum ohne Zeile = %q, want den Ersatz", got)
	}
}

// TestWelleDatumAusDerErgebnisnotiz liest das Abschluss-Datum der Welle; ohne
// Zeile steht der Leerwert.
func TestWelleDatumAusDerErgebnisnotiz(t *testing.T) {
	if got := archive.WelleDatum("**Abschluss:** 2026-08-01 (Beleg)\n"); got != "2026-08-01" {
		t.Errorf("WelleDatum = %q, want 2026-08-01", got)
	}
	if got := archive.WelleDatum("keine Zeile\n"); got != "—" {
		t.Errorf("WelleDatum ohne Zeile = %q, want —", got)
	}
}

// TestHervorgegangenBautAnkerLinks: jede Kennung wird als Anker-Link NEU gebaut —
// die Pfade der Closure-Notiz gelten fuer die flache done/-Ebene, der Stub liegt
// eine Ebene tiefer, und die ID-Link-Pflicht des Doku-Gates gilt im Stub. Eine
// ADR ohne Datei faellt aus dem Feld, statt einen toten Link zu tragen.
func TestHervorgegangenBautAnkerLinks(t *testing.T) {
	root := t.TempDir()
	schreibe(t, filepath.Join(root, "docs", "plan", "adr", "0033-wellen-archivierung.md"), "# ADR\n")
	schreibe(t, filepath.Join(root, "docs", "plan", "planning", "open", "slice-176-folge.md"), "# x\n")

	inhalt := strings.Join([]string{
		"## 7. Closure-Notiz",
		"- **Beobachtungs-Register:** BEO-ALL/commit-message-ohne-traceability-kennung auf 9x erhoeht",
		"- **Folge-Slices:** slice-176 (Titel) — liegt in `open/`; ADR-0033 traegt den Rest",
		"- **Risiken:** ADR-0099 wird hier nicht als Datei gefuehrt",
	}, "\n")

	got := archive.Hervorgegangen(root, inhalt, "welle-10")
	want := "[`BEO-ALL/commit-message-ohne-traceability-kennung`](../../observations/BEO-ALL/commit-message-ohne-traceability-kennung/observation.md) · " +
		"[`ADR-0033`](../../../adr/0033-wellen-archivierung.md) · [slice-176](../../open/slice-176-folge.md)"
	if got != want {
		t.Fatalf("Hervorgegangen =\n%q\nwant\n%q", got, want)
	}
	if got := archive.Hervorgegangen(root, "## 7\n- **Was lief anders:** nichts\n", "welle-10"); got != "— keine —" {
		t.Fatalf("ohne Ausgangs-Zeile = %q, want den Leerwert", got)
	}
}

// TestHervorgegangenAlteDreistelligeFormBleibtUnerkannt haelt die im
// Funktionskopf von beoRE begruendete Entscheidung: die vor ADR-0034 gefuehrte
// Form `BEO-NNN` wird NICHT mehr erkannt — eine Zeile, die nur sie traegt,
// liefert den Leerwert statt eines Links, den niemand aufloesen koennte.
func TestHervorgegangenAlteDreistelligeFormBleibtUnerkannt(t *testing.T) {
	inhalt := "## 7\n- **Beobachtungs-Register:** BEO-009 auf 9x erhoeht\n"
	if got := archive.Hervorgegangen(t.TempDir(), inhalt, "welle-10"); got != "— keine —" {
		t.Fatalf("Hervorgegangen = %q, want den Leerwert (alte Form nicht mehr erkannt)", got)
	}
}

// TestHervorgegangenUebernimmtBenannteSliceKennung: eine Folge-Slice-Kennung
// ohne Ziffern-Praefix (lowercase Kebab-Case) wird ERKANNT UND AUFGELOEST,
// wenn ihre Datei noch im Lifecycle liegt — mit demselben Anker-Link, den
// eine nummerierte Kennung bekaeme. Die Datei traegt hier KEINEN Titel-Suffix
// (`slice-<slug>.md`, MR-057 Setzung 1) — anders als eine nummerierte, die
// immer einen Titel-Suffix hinter der Nummer traegt.
func TestHervorgegangenUebernimmtBenannteSliceKennung(t *testing.T) {
	root := t.TempDir()
	schreibe(t, filepath.Join(root, "docs", "plan", "planning", "open", "slice-benannter-slug.md"), "# x\n")
	inhalt := "## 7. Closure-Notiz\n- **Folge-Slices:** slice-benannter-slug (Titel) — liegt in `open/`\n"

	got := archive.Hervorgegangen(root, inhalt, "welle-10")
	want := "[slice-benannter-slug](../../open/slice-benannter-slug.md)"
	if got != want {
		t.Fatalf("Hervorgegangen = %q, want %q", got, want)
	}
}

// TestHervorgegangenBenannteKennungOhneDateiBleibtBar: eine benannte Kennung,
// die der Lifecycle nicht mehr fuehrt (keine Datei unter irgendeiner der
// beiden Formen aus sliceDateiMuster aufloesbar), steht bar da statt mit
// einem toten Link — dieselbe Regel wie fuer eine nummerierte Kennung ohne
// Datei (siehe TestSlicePfadRelativLiefertDieAufsteigendeForm, Fall "999").
func TestHervorgegangenBenannteKennungOhneDateiBleibtBar(t *testing.T) {
	root := t.TempDir()
	inhalt := "## 7. Closure-Notiz\n- **Folge-Slices:** slice-nie-angelegter-slug (Titel) — liegt in `open/`\n"

	got := archive.Hervorgegangen(root, inhalt, "welle-10")
	want := "slice-nie-angelegter-slug"
	if got != want {
		t.Fatalf("Hervorgegangen = %q, want %q (kein Lifecycle-Treffer)", got, want)
	}
}

// TestHervorgegangenMischtBenannteUndNummerierteSliceKennung: eine Zeile mit
// beiden Formen liefert fuer BEIDE den Anker-Link, wenn beide Dateien
// existieren — Boundary-Fall fuer die erweiterte Erkennung ueber die
// Ziffern-Grenze hinweg.
func TestHervorgegangenMischtBenannteUndNummerierteSliceKennung(t *testing.T) {
	root := t.TempDir()
	schreibe(t, filepath.Join(root, "docs", "plan", "planning", "open", "slice-176-folge.md"), "# x\n")
	schreibe(t, filepath.Join(root, "docs", "plan", "planning", "open", "slice-benannter-slug.md"), "# x\n")
	inhalt := "## 7\n- **Folge-Slices:** slice-176 (A) und slice-benannter-slug (B) — liegt in `open/`\n"

	got := archive.Hervorgegangen(root, inhalt, "welle-10")
	want := "[slice-176](../../open/slice-176-folge.md) · [slice-benannter-slug](../../open/slice-benannter-slug.md)"
	if got != want {
		t.Fatalf("Hervorgegangen =\n%q\nwant\n%q", got, want)
	}
}

// TestSliceKennungAusTitelSuffixBleibtDieNummer: eine Folge-Slices-Zeile mit
// dem VOLLEN Dateinamen (Titel-Suffix hinter der Nummer, wie ihn Autoren aus
// einem Datei-Browser oder einer Dateiliste kopieren) liefert die
// nummerierte Kennung ALLEIN — die Alternativen-Reihenfolge in sliceRE ist
// dafuer tragend (Go waehlt leftmost-first, nicht leftmost-longest).
// Gegenbeispiel: test/mutations/318-stub-slicere-alternativen-reihenfolge.sh.
func TestSliceKennungAusTitelSuffixBleibtDieNummer(t *testing.T) {
	inhalt := "## 7\n- **Folge-Slices:** slice-170-archivierungs-werkzeug — liegt in `open/`\n"

	got := archive.Hervorgegangen(t.TempDir(), inhalt, "welle-10")
	want := "slice-170"
	if got != want {
		t.Fatalf("Hervorgegangen = %q, want %q (Titel-Suffix darf nicht in die Kennung wandern)", got, want)
	}
}

// TestHervorgegangenFliesstextTokenBleibtVonEchterKennungUnunterscheidbar
// haelt eine GEMESSENE GRENZE fest, keine Zusage: ein Fliesstext-Token
// "slice-mv" (aus einem Befehlsnamen wie "make slice-mv"), das keine Datei
// im Lifecycle referenziert, erscheint bar — genau wie eine echte benannte
// Kennung ohne (mehr) aufloesbare Datei (siehe
// TestHervorgegangenBenannteKennungOhneDateiBleibtBar). Ein Existenz-Guard
// wie in harness/tools/slice-mv.sh rewrite_outgoing_bare_in_file() gibt es
// fuer die Go-Seite nicht (Grenze, dokumentiert am Funktionskopf von
// Hervorgegangen()).
func TestHervorgegangenFliesstextTokenBleibtVonEchterKennungUnunterscheidbar(t *testing.T) {
	root := t.TempDir()
	inhalt := "## 7\n- **Folge-Slices:** keine; der Nachzug via `make slice-mv` genuegt\n"

	got := archive.Hervorgegangen(root, inhalt, "welle-10")
	want := "slice-mv"
	if got != want {
		t.Fatalf("Hervorgegangen = %q, want %q (dokumentierte Grenze, kein Existenz-Guard)", got, want)
	}
}

// TestSlicePfadRelativLiefertDieAufsteigendeForm: ein Folge-Slice, der noch flach
// in done/ liegt, wird vom Stub aus mit `../<datei>.md` adressiert. Genau diese
// Form schreibt das Werkzeug damit selbst in den Bestand — sie ist der Grund, aus
// dem der Verweis-Nachzug eine dritte Ersetzungsrichtung fuehrt. Dieselben vier
// Lagen tragen eine BENANNTE Kennung (Datei exakt, kein Titel-Suffix) ebenso wie
// eine nummerierte (Titel-Suffix hinter der Nummer) — beide Formen aus
// sliceDateiMuster nebeneinander im selben Fall-Katalog.
func TestSlicePfadRelativLiefertDieAufsteigendeForm(t *testing.T) {
	root := t.TempDir()
	done := filepath.Join(root, "docs", "plan", "planning", "done")
	schreibe(t, filepath.Join(done, "slice-176-flach.md"), "# x\n")
	schreibe(t, filepath.Join(done, "welle-09", "slice-177-frueher.md"), "# x\n")
	schreibe(t, filepath.Join(done, "welle-10", "slice-178-eigen.md"), "# x\n")
	schreibe(t, filepath.Join(root, "docs", "plan", "planning", "next", "slice-179-offen.md"), "# x\n")
	schreibe(t, filepath.Join(done, "slice-flach-benannt.md"), "# x\n")
	schreibe(t, filepath.Join(done, "welle-09", "slice-frueher-benannt.md"), "# x\n")
	schreibe(t, filepath.Join(done, "welle-10", "slice-eigen-benannt.md"), "# x\n")
	schreibe(t, filepath.Join(root, "docs", "plan", "planning", "next", "slice-offen-benannt.md"), "# x\n")

	faelle := []struct{ kennung, want string }{
		{"178", "slice-178-eigen.md"},
		{"176", "../slice-176-flach.md"},
		{"177", "../welle-09/slice-177-frueher.md"},
		{"179", "../../next/slice-179-offen.md"},
		{"999", ""},
		{"eigen-benannt", "slice-eigen-benannt.md"},
		{"flach-benannt", "../slice-flach-benannt.md"},
		{"frueher-benannt", "../welle-09/slice-frueher-benannt.md"},
		{"offen-benannt", "../../next/slice-offen-benannt.md"},
		{"nie-existierender-slug", ""},
	}
	for _, f := range faelle {
		if got := archive.SlicePfadRelativ(root, f.kennung, "welle-10"); got != f.want {
			t.Errorf("SlicePfadRelativ(%s) = %q, want %q", f.kennung, got, f.want)
		}
	}
}

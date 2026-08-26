package emit_test

import (
	"bytes"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/emit"
	"github.com/pt9912/ai-harness-init/internal/span"
)

// emittierteFeldliste faehrt einen echten Emit in ein frisches Verzeichnis und liefert den
// Inhalt der abgelegten Feldliste. GELESEN wird von der Platte, nicht aus dem Speicher: die
// Zusage gilt der Datei im Ziel, nicht dem Rueckgabewert einer Funktion.
func emittierteFeldliste(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	var notice bytes.Buffer
	if err := emit.Enforce(dir, &notice); err != nil {
		t.Fatalf("Enforce: %v", err)
	}
	if notice.Len() != 0 {
		t.Fatalf("die Traeger-Ablage scheiterte in dieser Umgebung — der Gelingens-Zweig ist hier nicht messbar: %s", notice.String())
	}
	return mustReadString(t, filepath.Join(dir, filepath.FromSlash(emit.FieldListPath)))
}

// grenzSatzSteht prueft EINEN der drei stehenden Grenz-Saetze im emittierten Dokument.
// Verglichen wird gegen leerraum-normalisierten Text, damit der Zeilenumbruch des Dokuments
// keine Rolle spielt; die Bestandteile stehen im Waechter und nicht im geprueften Text —
// sonst pruefte er eine Zeichenkette gegen sich selbst.
//
// GRENZE DIESER WAECHTER, benannt: sie messen die ANWESENHEIT eines Satzes, nicht seine
// WAHRHEIT. Ob die emittierte Ebene wirklich keinen Waechter ueber die Aufrufform fuehrt,
// prueft keiner von ihnen — das waere ein Sensor ueber einem fremden Vertrag.
func grenzSatzSteht(t *testing.T, benennung string, teile ...string) {
	t.Helper()
	doc := strings.Join(strings.Fields(emittierteFeldliste(t)), " ")
	for _, teil := range teile {
		if !strings.Contains(doc, teil) {
			t.Errorf("die emittierte Feldliste fuehrt die Grenze %q nicht vollstaendig — es fehlt: %q", benennung, teil)
		}
	}
}

// TestFeldliste_LiegtVerbatimImZiel haelt die Transport-Haelfte der Zusage aus ADR-0022
// Festlegung 7: was im Ziel liegt, ist BYTE-GLEICH mit dem, was der Traeger ueber sein
// eigenes Schema ausgibt — kein Kopf, kein Stempel, keine Ersetzung (Muster MR-010).
//
// WAS ER NICHT DECKT, weil beide Seiten aus derselben Funktion kommen: ob der INHALT die
// Erfassung trifft. Das messen die Waechter in internal/span/fieldlist_test.go gegen den
// reflektierten Span-Typ.
func TestFeldliste_LiegtVerbatimImZiel(t *testing.T) {
	ausdruck, err := span.FieldList()
	if err != nil {
		t.Fatalf("span.FieldList: %v", err)
	}
	if got := emittierteFeldliste(t); got != ausdruck {
		t.Errorf("die emittierte Feldliste ist nicht byte-gleich mit dem Ausdruck des Traegers\n--- im Ziel ---\n%s\n--- Ausdruck ---\n%s", got, ausdruck)
	}
}

// TestFeldliste_LiegtMitDemTraeger misst den Gelingens-Zweig aus ADR-0022 Festlegung 5(a):
// laeuft die Traeger-Ablage durch, liegt die Feldliste im Ziel — und zwar nicht leer.
func TestFeldliste_LiegtMitDemTraeger(t *testing.T) {
	doc := emittierteFeldliste(t)
	if !strings.HasPrefix(doc, "# ") {
		t.Errorf("die emittierte Feldliste beginnt nicht mit einer Ueberschrift:\n%s", doc)
	}
	if !strings.Contains(doc, "| Feld | Pflicht |") {
		t.Errorf("die emittierte Feldliste traegt keine Feldtabelle:\n%s", doc)
	}
}

// TestFeldliste_KeineFeldlisteOhneTraeger misst den ANDEREN Zweig — und er ist der Grund,
// warum der Waechter oben BEDINGT formuliert ist. Scheitert die Ablage des Traegers,
// entsteht die Feldliste NICHT: sie ist der Ausdruck einer Erfassung, die dann nicht im
// Ziel liegt. Ein unbedingt geschriebenes Dokument stuende gegen die Zusage aus
// LH-FA-10, dass in diesem Zweig begruendet NICHTS abgelegt wird.
//
// Der blockierte Ablageort ist derselbe Aufbau wie in TestEnforce_KeineErfassungOhneTraeger:
// eine DATEI dort, wo ein Verzeichnis entstehen muesste.
func TestFeldliste_KeineFeldlisteOhneTraeger(t *testing.T) {
	dir := t.TempDir()
	blocker := filepath.Join(dir, filepath.FromSlash(".harness/state/bin"))
	if err := os.MkdirAll(filepath.Dir(blocker), 0o755); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	if err := os.WriteFile(blocker, []byte("kein Verzeichnis\n"), 0o644); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	var notice bytes.Buffer
	if err := emit.Enforce(dir, &notice); err != nil {
		t.Fatalf("der Bootstrap muss ohne Erfassung ERFOLGREICH enden, bekam: %v", err)
	}
	if notice.Len() == 0 {
		t.Fatalf("der Fehlerzweig wurde nicht genommen — dieser Waechter misst dann den falschen Zweig")
	}
	if _, err := os.Stat(filepath.Join(dir, filepath.FromSlash(emit.FieldListPath))); err == nil {
		t.Errorf("ohne abgelegten Traeger liegt trotzdem eine Feldliste in %s — sie behauptet eine Erfassung, die das Ziel nicht hat", emit.FieldListPath)
	}
}

// TestFeldliste_LiegtImGeprueftenBereich haelt die Ortswahl aus ADR-0022 Festlegung 7 gegen
// die EMITTIERTE .d-check.yml statt gegen einen abgeschriebenen Pfad: kein Ausschluss ihrer
// scan.ignore-Liste darf die Feldliste treffen. Sonst laege eine Aussage an den Adopter in
// dem Baum, den sein Doku-Gate ueberspringt — und die Zusage „im geprueften Bereich" waere
// eine Adresse ohne Wirkung.
//
// FAIL-CLOSED bei einer unbekannten Muster-Form: ein Ausschluss, den dieser Waechter nicht
// deuten kann, ist ein Ausschluss, ueber den er nichts sagen kann — dann faellt er, statt
// still gruen zu bleiben (MR-017).
func TestFeldliste_LiegtImGeprueftenBereich(t *testing.T) {
	zeile := regexp.MustCompile(`(?m)^\s*ignore:\s*\[(.*)\]\s*$`)
	treffer := zeile.FindStringSubmatch(emit.DCheckConfig())
	if treffer == nil {
		t.Fatalf("die emittierte .d-check.yml traegt keine ignore-Liste — der Waechter misst nichts:\n%s", emit.DCheckConfig())
	}
	var geprueft int
	for _, roh := range strings.Split(treffer[1], ",") {
		muster := strings.Trim(strings.TrimSpace(roh), `"`)
		if muster == "" {
			continue
		}
		geprueft++
		switch {
		case strings.HasSuffix(muster, "/**"):
			if praefix := strings.TrimSuffix(muster, "**"); strings.HasPrefix(emit.FieldListPath, praefix) {
				t.Errorf("die Feldliste liegt unter %s und faellt damit aus dem geprueften Bereich des Ziels (scan.ignore %q)", emit.FieldListPath, muster)
			}
		case strings.HasPrefix(muster, "**/*"):
			if endung := strings.TrimPrefix(muster, "**/*"); strings.HasSuffix(emit.FieldListPath, endung) {
				t.Errorf("die Feldliste heisst %s und faellt damit aus dem geprueften Bereich des Ziels (scan.ignore %q)", emit.FieldListPath, muster)
			}
		default:
			t.Errorf("scan.ignore fuehrt das Muster %q in einer Form, die dieser Waechter nicht deuten kann — er kann ueber sie nichts zusagen", muster)
		}
	}
	if geprueft == 0 {
		t.Fatalf("die ignore-Liste der emittierten .d-check.yml ist leer — der Waechter misst nichts")
	}
}

// TestFeldliste_OhneMarkdownLink haelt die Gate-Sicherheit, die aus der Ortswahl folgt: das
// Dokument liegt im geprueften Bereich des Ziels und wird damit zum Gate-Gegenstand des
// Adopters. Ein toter relativer Verweis darin faerbte sein Doku-Gate rot, und er koennte
// ihn nicht heilen — die Datei ist konvergent, ein Re-Lauf setzt sie zurueck. Also traegt
// sie gar keinen Verweis.
func TestFeldliste_OhneMarkdownLink(t *testing.T) {
	doc := emittierteFeldliste(t)
	if strings.Contains(doc, "](") {
		t.Errorf("die emittierte Feldliste traegt einen Markdown-Verweis — im Ziel kann ihn niemand heilen:\n%s", doc)
	}
}

// TestFeldliste_GrenzeAufrufform misst den ERSTEN stehenden Grenz-Satz (ADR-0022
// Festlegung 7, LH-FA-10 §Benannte Grenze): die emittierte Ebene fuehrt keinen Waechter
// ueber die Aufrufform des Agenten-Werkzeugs, und die Richtung gehoert dazu — die
// Rollen-Achse ruht dort auf Adopter-Disziplin, und ein leeres Feld heisst unbekannt,
// nie rollenlos.
func TestFeldliste_GrenzeAufrufform(t *testing.T) {
	grenzSatzSteht(t, "kein Wächter über die Aufrufform",
		"Über die Aufrufform des Agenten-Werkzeugs führt diese Ebene keinen Wächter",
		"leer heißt unbekannt, nie rollenlos",
		"ruht hier auf Disziplin",
	)
}

// TestFeldliste_GrenzeVerbrauchsZaehler misst den ZWEITEN Satz (ADR-0021 Folgepflicht 6,
// hier eingeloest statt weitergereicht): die Verbrauchs-Zaehler kommen aus der Mechanik
// des Agenten-Werkzeugs nicht, und kein Lauf des Adopters fuehrt sie herbei. Eine
// Abdeckungs-Zeile in einem Bericht meldet einen ZUSTAND; erst dieser Satz nennt die
// GRENZE, und er gilt auch, wenn niemand den Bericht ruft.
func TestFeldliste_GrenzeVerbrauchsZaehler(t *testing.T) {
	grenzSatzSteht(t, "Verbrauchs-Zähler ohne Quelle",
		"Die Verbrauchs-Zähler kommen aus der Mechanik des Agenten-Werkzeugs nicht",
		"Kein Lauf dieses Repos führt sie herbei",
		"keine Eigenschaft dieses Aufbaus, sondern der Mechanik",
	)
}

// TestFeldliste_GrenzeUeberDenBestand misst den DRITTEN Satz (LH-FA-10 §Redaktion,
// ADR-0022 Festlegung 6 Stueck 3): ueber den Bestand ist nichts zugesagt. Die vier
// Bestandteile sind vier Aussagen, nicht eine — gitignored, nicht verschluesselt, nicht
// zugriffsbeschraenkt, und Pfadnamen ausdruecklich nicht als unkritisch zugesagt.
func TestFeldliste_GrenzeUeberDenBestand(t *testing.T) {
	grenzSatzSteht(t, "keine Zusage über den Bestand",
		"Über den Bestand ist nichts zugesagt",
		"**gitignored**",
		"**nicht verschlüsselt**",
		"**nicht zugriffsbeschränkt**",
		"**Pfadnamen sind nicht als unkritisch zugesagt**",
	)
}

// TestFeldliste_Konvergent misst die einzige Zusage, die das Dokument ueber sich selbst
// macht: „Ein erneuter Lauf des Werkzeugs schreibt diese Datei kanonisch neu." Eine von
// Hand geaenderte Feldliste wird also geheilt, nicht stehen gelassen — sonst beschriebe
// sie nach der ersten Schema-Aenderung eine Erfassung, die es nicht mehr gibt, und der
// Satz im Dokument waere falsch.
//
// In der Gestalt von TestEnforce_Convergent: die Drift liegt VOR dem Lauf, der Lauf ist
// der Re-Lauf. Der Dauer-Sensor ist test/mutations/172-feldliste-nicht-konvergent.sh.
func TestFeldliste_Konvergent(t *testing.T) {
	dir := t.TempDir()
	dst := filepath.Join(dir, filepath.FromSlash(emit.FieldListPath))
	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	if err := os.WriteFile(dst, []byte("von Hand geaendert\n"), 0o644); err != nil {
		t.Fatalf("vorbereiten: %v", err)
	}
	var notice bytes.Buffer
	if err := emit.Enforce(dir, &notice); err != nil {
		t.Fatalf("Enforce (konvergent darf nicht refusen): %v", err)
	}
	if notice.Len() != 0 {
		t.Fatalf("die Traeger-Ablage scheiterte in dieser Umgebung — der Gelingens-Zweig ist hier nicht messbar: %s", notice.String())
	}
	ausdruck, err := span.FieldList()
	if err != nil {
		t.Fatalf("span.FieldList: %v", err)
	}
	// Nicht nur „die Drift ist weg": geprueft wird der KANONISCHE Stand. Ein Re-Lauf, der
	// die Datei leerte oder kuerzte, haette die Drift auch entfernt.
	if got := mustReadString(t, dst); got != ausdruck {
		t.Errorf("der Re-Lauf schrieb die Feldliste nicht kanonisch neu — im Ziel steht:\n%s", got)
	}
}

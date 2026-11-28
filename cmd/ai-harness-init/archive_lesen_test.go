package main

// Die Leseprobe des Traeger-Unterkommandos archive-lesen: das Archiv liess sich
// oeffnen und jeder Eintrag las sich bis zum Ende, und jeder genannte Eintrag
// liegt in der Namensliste. Der Verletzungs-Inhalt wird am echten Zip-Layout
// gebaut: ein STORED-Eintrag traegt seinen Inhalt unkomprimiert, darum liegt
// der Inhalt byte-genau im Archiv und der letzte Inhalts-Byte laesst sich
// allein verfaelschen — Kopfzeile und Verzeichnis bleiben unberuehrt, das Archiv
// oeffnet und listet noch, nur das Lesen des Eintrags faellt an der CRC.
import (
	"archive/zip"
	"bytes"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

// inhaltsMuster ist eindeutig im Archiv-Layout: der Inhalt des STORED-Eintrags
// liegt genau einmal in den Archiv-Bytes (Kopfzeile und Verzeichnis tragen den
// Namen, nicht den Inhalt).
const inhaltsMuster = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123"

func schreibeStoredZip(t *testing.T, name string, inhalt []byte) []byte {
	t.Helper()
	var puffer bytes.Buffer
	zw := zip.NewWriter(&puffer)
	zh := &zip.FileHeader{Name: name, Method: zip.Store}
	schreiber, fehler := zw.CreateHeader(zh)
	if fehler != nil {
		t.Fatalf("CreateHeader: %v", fehler)
	}
	if _, fehler := schreiber.Write(inhalt); fehler != nil {
		t.Fatalf("Eintrag schreiben: %v", fehler)
	}
	if fehler := zw.Close(); fehler != nil {
		t.Fatalf("Zip abschliessen: %v", fehler)
	}
	return puffer.Bytes()
}

func legeZipAb(t *testing.T, bytesInhalt []byte) string {
	t.Helper()
	pfad := filepath.Join(t.TempDir(), "probe.zip")
	if fehler := os.WriteFile(pfad, bytesInhalt, 0o644); fehler != nil {
		t.Fatalf("Zip ablegen: %v", fehler)
	}
	return pfad
}

func TestArchiveLesen_LiestUndHaeltBenannte(t *testing.T) {
	archiv := legeZipAb(t, schreibeStoredZip(t, "a.txt", []byte(inhaltsMuster)))
	var aus, fehleraus bytes.Buffer
	rc := archiveLesen([]string{archiv, "a.txt"}, &aus, &fehleraus)
	if rc != 0 {
		t.Fatalf("archive-lesen endet mit Exit %d, erwartet 0. stderr: %s", rc, fehleraus.String())
	}
	if got := aus.String(); !strings.Contains(got, "a.txt") {
		t.Errorf("stdout nennt den Eintrag nicht: %q", got)
	}
}

func TestArchiveLesen_FehlenderEintragBrichtAb(t *testing.T) {
	archiv := legeZipAb(t, schreibeStoredZip(t, "a.txt", []byte(inhaltsMuster)))
	var aus, fehleraus bytes.Buffer
	rc := archiveLesen([]string{archiv, "fehlt.txt"}, &aus, &fehleraus)
	if rc == 0 {
		t.Fatal("archive-lesen haelt einen fehlenden Eintrag nicht ab")
	}
	if !strings.Contains(fehleraus.String(), "fuehrt den Eintrag fehlt.txt nicht") {
		t.Errorf("der Abbruch nennt den fehlenden Eintrag nicht: %q", fehleraus.String())
	}
}

func TestArchiveLesen_AbgeschnittenesArchivBrichtAb(t *testing.T) {
	ganz := schreibeStoredZip(t, "a.txt", []byte(inhaltsMuster))
	// Ende weg: ohne die zentrale Verzeichnis-Spur oeffnet nichts mehr.
	archiv := legeZipAb(t, ganz[:len(ganz)-30])
	var aus, fehleraus bytes.Buffer
	rc := archiveLesen([]string{archiv}, &aus, &fehleraus)
	if rc == 0 {
		t.Fatal("archive-lesen haelt ein abgeschnittenes Archiv nicht ab")
	}
	if !strings.Contains(fehleraus.String(), "nicht lesbar") {
		t.Errorf("der Abbruch nennt die Unlesbarkeit nicht: %q", fehleraus.String())
	}
}

// TestArchiveLesen_VerletzterEintragBrichtAb ist der Zahn fuer die Lesung selbst:
// das verfaelschte Inhalts-Byte faellt erst beim Lesen bis zum Ende (CRC), nicht
// beim Oeffnen oder im Namen. Mutations-Anlage 829 enthemmt die Lesung — unter
// ihr bleibt der Lauf gruen, weil nur noch Namen gelesen werden.
func TestArchiveLesen_VerletzterEintragBrichtAb(t *testing.T) {
	ganz := schreibeStoredZip(t, "a.txt", []byte(inhaltsMuster))
	stelle := bytes.Index(ganz, []byte(inhaltsMuster))
	if stelle < 0 {
		t.Fatal("der Eintrag-Inhalt liegt nicht im Archiv-Layout — der Verletzungs-Zug misst nichts")
	}
	falsch := append([]byte(nil), ganz...)
	falsch[stelle+len(inhaltsMuster)-1] ^= 0xFF
	archiv := legeZipAb(t, falsch)
	var aus, fehleraus bytes.Buffer
	rc := archiveLesen([]string{archiv}, &aus, &fehleraus)
	if rc == 0 {
		t.Fatal("archive-lesen haelt ein Archiv mit verletztem Eintrag-Inhalt nicht ab")
	}
	if !strings.Contains(fehleraus.String(), "Eintrag a.txt nicht lesbar") {
		t.Errorf("der Abbruch nennt den verletzten Eintrag nicht: %q", fehleraus.String())
	}
}

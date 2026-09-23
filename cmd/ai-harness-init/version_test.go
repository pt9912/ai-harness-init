package main

import (
	"bytes"
	"strings"
	"testing"
)

// TestVersionMeldetDieInjizierteFassung haelt die Ausgabe an den uebergebenen
// Fassungs-Wert (ADR-0063 Festlegung 1): mit Injektion meldet `--version` exakt
// diesen Wert auf stdout, Exit 0, stderr leer. Rot-Gegenprobe:
// test/mutations/400-fassung-meldet-falschen-wert.sh meldet einen festen Wert
// statt der Injektion und faellt hier; den ldflags-Weg am Bau haelt
// test/release-matrix.bats.
func TestVersionMeldetDieInjizierteFassung(t *testing.T) {
	fassung = "v9.9.9-mutprobe"
	defer func() { fassung = "" }()
	var out, errb bytes.Buffer
	code := run([]string{"--version"}, "", testSources(t), &out, &errb)
	if code != 0 {
		t.Fatalf("Exit %d mit Injektion, want 0 — stderr: %q", code, errb.String())
	}
	if got := out.String(); got != "v9.9.9-mutprobe\n" {
		t.Errorf("stdout meldet %q, want %q — der gemeldete Wert haengt an der Injektion, nicht an einer Konstanten", got, "v9.9.9-mutprobe\n")
	}
	if errb.Len() > 0 {
		t.Errorf("stderr ist mit Injektion leer: %q", errb.String())
	}
}

// TestVersionFehltFallIstLaut haelt den Fehlt-Fall an Wortlaut und Exit
// (ADR-0063 Festlegung 2): ohne Injektion meldet `--version` den dokumentierten
// Wortlaut auf stderr und bricht mit 2 ab — nicht leer, nicht der Pin-Wert des
// Builds, kein stiller Ausgang. Unter der geschwaechten Zusage (leere Ausgabe,
// Pin-Wert statt Meldung, Exit 0) bleibt der Fall rot; Rot-Gegenprobe:
// test/mutations/399-fassung-fehlt-fall-entstaerkt.sh. Der Zielordner bleibt
// unberuehrt: der Ausgang loest sich im Dispatch, nicht im Init-Pfad.
func TestVersionFehltFallIstLaut(t *testing.T) {
	var out, errb bytes.Buffer
	code := run([]string{"--version"}, "", testSources(t), &out, &errb)
	if code != 2 {
		t.Fatalf("Exit %d ohne Injektion, want 2 (ADR-0063 Festlegung 2) — stderr: %q", code, errb.String())
	}
	if !strings.Contains(errb.String(), "keine Fassung injiziert") {
		t.Errorf("stderr nennt den Fehlt-Fall nicht beim Wortlaut: %q", errb.String())
	}
	if !strings.Contains(errb.String(), "keinen geschnittenen Tag") {
		t.Errorf("stderr benennt den Zustand des Binary nicht: %q", errb.String())
	}
	if out.Len() > 0 {
		t.Errorf("stdout ist im Fehlt-Fall leer: %q", out.String())
	}
}
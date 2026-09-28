//go:build resourcecap

// Package resourcecap traegt den Waechter fuer den Prozess-Deckel des Testlaufs: eine
// feste Zahl gleichzeitiger Prozesse muss unter dem in der Makefile gesetzten
// TEST_PIDS_LIMIT scheitern und ohne ihn durchlaufen. Der Build-Tag haelt diese Datei
// aus dem Standard-Testlauf (`go test ./...`) heraus — sie erzeugt absichtlich Druck an
// genau der Grenze, die der Rest der Suite unangetastet lassen soll; make
// test-go-pids-guard fuehrt sie isoliert, mit demselben Deckel wie make test-go.
package resourcecap

import (
	"fmt"
	"os/exec"
	"testing"
)

// forkCount uebersteigt TEST_PIDS_LIMIT (Makefile) mit deutlichem Abstand — fest,
// nicht rekursiv: keine Prozess-Bombe, nur genug, um den konfigurierten Deckel sicher
// zu ueberschreiten, wenn er greift. Die Last startet eine einzelne Shell (ein Prozess
// dieses Go-Tests), die ihrerseits forkCount Kind-Prozesse anstoesst — nicht forkCount
// eigene Goroutinen: Eine Goroutine je Kind-Prozess haengt in einem blockierenden Wait,
// und das zwingt den Go-Scheduler zu zusaetzlichen Betriebssystem-Threads, die selbst
// um denselben pids-Deckel konkurrieren wie die eigentliche Last.
const forkCount = 700

// TestFesteLastUeberschreitetPidsDeckel startet forkCount Prozesse gleichzeitig und
// erwartet, dass mindestens einer am pids-limit scheitert — die Shell selbst bricht
// dann mit einem Fork-Fehler ab (beobachtet, nicht aus der cgroup-Konfiguration
// gelesen). Ohne Deckel (kein --pids-limit am docker run) laufen alle forkCount
// Prozesse durch, die Shell endet regulaer, und der Test wird rot.
func TestFesteLastUeberschreitetPidsDeckel(t *testing.T) {
	script := fmt.Sprintf(`for ((i=0;i<%d;i++)); do sleep 2 & done; wait`, forkCount)
	cmd := exec.Command("bash", "-c", script)
	out, err := cmd.CombinedOutput()
	if err == nil {
		t.Fatalf("Ressourcen-Deckel greift nicht: %d gleichzeitig gestartete Prozesse liefen alle durch (Shell endete regulaer) — erwartet war, dass der in der Makefile gesetzte TEST_PIDS_LIMIT mindestens einen Start verhindert", forkCount)
	}
	t.Logf("Shell scheiterte wie erwartet (%v), Ausgabe:\n%s", err, out)
}

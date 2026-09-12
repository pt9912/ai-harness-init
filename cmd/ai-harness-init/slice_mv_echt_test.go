package main

import (
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

// sliceMvSkript ist der repo-relative Pfad zum echten Shell-Traeger, aufgeloest
// vom Arbeitsverzeichnis dieses Test-Pakets aus (go test setzt es auf das
// Quellverzeichnis). Die Dockerfile-test-Stufe kopiert den ganzen Baum
// (COPY . .), das Skript liegt also in jedem Lauf von make test-go daneben.
const sliceMvSkript = "../../harness/tools/slice-mv.sh"

// sliceMvRepo baut das kleinste Repo, an dem main() von slice-mv.sh die
// EINGEHEND-Ausnahme fuer docs/plan/adr real durchlaeuft: eine Slice-Datei in
// open/, eine ADR UND ein Review-Report, die beide per Praefix-Form auf sie
// zeigen (ADR-0042 Festlegung 2 nimmt die ADR aus, ADR-0033
// Abnahme-Kriterium 1 haelt docs/reviews/** im Suchraum). Der Shell-Traeger
// selbst wird MIT hineinkopiert, weil er ueber "$(dirname "$0")/../.." seine
// eigene Position als Repo-Wurzel bestimmt — am Original ausgefuehrt wuerde er
// in DIESEM Repo wirken, nicht im Pruef-Repo.
func sliceMvRepo(t *testing.T) string {
	t.Helper()
	root := t.TempDir()
	schreibeDatei(t, root, "docs/plan/planning/open/slice-900-x.md", "# Slice slice-900\n")
	schreibeDatei(t, root, "docs/plan/adr/0001-x.md",
		"# ADR-0001\n\nBeleg: [Slice](../planning/open/slice-900-x.md)\n")
	schreibeDatei(t, root, "docs/reviews/2026-01-01-x.md",
		"# Review\n\nBeleg: [Slice](../plan/planning/open/slice-900-x.md)\n")

	skript, err := os.ReadFile(sliceMvSkript)
	if err != nil {
		t.Fatalf("Shell-Traeger nicht lesbar (%s): %v", sliceMvSkript, err)
	}
	schreibeDatei(t, root, "harness/tools/slice-mv.sh", string(skript))

	gitLauf(t, root, "init", "-q")
	gitLauf(t, root, "config", "user.email", "harness@example.invalid")
	gitLauf(t, root, "config", "user.name", "Harness Test")
	gitLauf(t, root, "add", "-A")
	gitLauf(t, root, "commit", "-q", "-m", "Ausgangsstand")
	return root
}

// TestSliceMvEchtUebergehtAcceptedADRBeimNachzug faehrt main() als echten
// bash-Prozess gegen ein Repo mit lebenden Verweisen aus einer ADR UND einem
// Review-Report auf dieselbe zu bewegende Slice-Datei (das gepinnte BATS_IMAGE
// fuehrt kein git, s. Skriptkopf slice-mv.sh Abschnitt BELEG — dieser Test
// laeuft darum in test-go, wo `git` real verfuegbar ist, wie schon
// TestArchiveWelleEchtSperrtAmHaengendenVerweis in dieser Datei zeigt).
//
// ADR-0042 Festlegung 2: der Verweis-Nachzug laesst die ADR unberuehrt.
// ADR-0033 Abnahme-Kriterium 1: docs/reviews/** bleibt im Suchraum, der
// Report bekommt seinen Verweis auf die neue Adresse.
//
// Gegenbeispiel: test/mutations/315-slice-mv-main-verliert-ausnahmeliste.sh
// kappt in main() die Verbindung zwischen der Ausnahmeliste und ihrer
// Benutzung im git-grep-Aufruf — test/slice-mv.bats sieht das nicht, weil es
// nur die Liste selbst prueft, nie main()s Gebrauch davon.
func TestSliceMvEchtUebergehtAcceptedADRBeimNachzug(t *testing.T) {
	root := sliceMvRepo(t)

	cmd := exec.Command("bash", filepath.Join(root, "harness/tools/slice-mv.sh"), "slice-900", "next")
	cmd.Dir = root
	if out, err := cmd.CombinedOutput(); err != nil {
		t.Fatalf("slice-mv.sh: %v\n%s", err, out)
	}

	if _, err := os.Stat(filepath.Join(root, "docs/plan/planning/next/slice-900-x.md")); err != nil {
		t.Fatalf("Slice liegt nicht in next/: %v", err)
	}

	adr, err := os.ReadFile(filepath.Join(root, "docs/plan/adr/0001-x.md"))
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(adr), "open/slice-900-x.md") {
		t.Errorf("ADR wurde nachgezogen, sollte unberuehrt bleiben (ADR-0042 Festlegung 2):\n%s", adr)
	}

	report, err := os.ReadFile(filepath.Join(root, "docs/reviews/2026-01-01-x.md"))
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(report), "next/slice-900-x.md") {
		t.Errorf("Review-Report wurde NICHT nachgezogen, sollte es (ADR-0033 Abnahme-Kriterium 1):\n%s", report)
	}
}

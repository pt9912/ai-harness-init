package emit

import (
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
)

// rulesDir ist der .claude/rules/-Zweig im Ziel — ein Pfad, den das Agenten-Werkzeug
// fixiert, im Geiste der .claude/agents/- und .claude/commands/-Emissionen. Die drei
// Dateien dort sind KEINE Texte und tragen kein paths:-Frontmatter (MR-035 Setzung 5):
// je ein Symlink auf eine Quelle des Ziel-Baums, dessen Sitzungsstart-Ladung damit auf
// die kanonischen Quellen des Ziels selbst und den Regelwerk-Index der vendored
// Baseline rueckt.
const rulesDir = ".claude/rules"

// pointerFile ist ein Emissions-Eintrag der Quellen-Pointer: der exakte Name unter
// .claude/rules/ und sein Zielpfad, relativ zu .claude/rules/.
type pointerFile struct {
	name string
	ziel string
}

// pointerFiles bildet die drei Quellen-Pointer auf ihr Ziel ab — die GESCHLOSSENE Menge
// dieses Emits; die vier Modul-Pointer der Adopter-Auswahl (MR-035) gehoeren nicht
// hierher, sie sind eine Setzung dieses Repos, nicht des Ziels. Der Tag im Zielpfad des
// Baseline-Pointers kommt ueber den Bootstrap-Aufruf aus `fetch.DefaultTag` — die EINE
// Quelle, an der Zeiger und Baseline gemeinsam wandern (ein Pin-Bump beider ohne eine
// zweite Stelle, an die man vergessen koennte).
func pointerFiles(tag string) []pointerFile {
	return []pointerFile{
		{name: "AGENTS.md", ziel: "../../AGENTS.md"},
		{name: "harness-README.md", ziel: "../../harness/README.md"},
		{name: "regelwerk-README.md", ziel: "../../.harness/baseline/" + tag + "/regelwerk/README.md"},
	}
}

// RulesPaths liefert die Ziel-Relpfade der Quellen-Pointer (fuer Tests/Inspektion) —
// dieselbe Rolle wie AgentPaths: eine Liste, die den Ziel-Layout-Vertrag an EINER
// Stelle haelt.
func RulesPaths(tag string) []string {
	files := pointerFiles(tag)
	paths := make([]string, 0, len(files))
	for _, f := range files {
		paths = append(paths, rulesDir+"/"+f.name)
	}
	return paths
}

// Rules legt die drei Quellen-Pointer unter .claude/rules/ ab. BESTANDS-BEHANDLUNG je
// exaktem Namen: kein Bestand -> anlegen; bestehender Pointer mit anderem Zielpfad ->
// umsetzen (die Pointer-Reparatur, die den Tag im Baseline-Zielpfad nach einem
// Baseline-Sprung nachzieht); regular file -> unberuehrt (die Quelle ist Adopter-Boden,
// MR-035 Setzung 5 schliesst aus, fremden Wortlaut zu ueberschreiben). Ein Eintrag, der
// weder Datei noch Symlink ist (Verzeichnis, Device), ist ein Zustand, ueber den die
// Bestands-Behandlung nichts sagt — er bricht den Lauf ab, statt still drueberzulaufen.
//
// Der Aufruf steht im Bootstrap nach fetch.Baseline: ohne den vendored
// Baseline-Zweig loest der Baseline-Pointer beim Anlegen ins Leere, und die Emission
// haette einen Ziel-Zustand geschrieben, den kein Leser aufoesen kann.
func Rules(targetDir, tag string) error {
	for _, f := range pointerFiles(tag) {
		rel := rulesDir + "/" + f.name
		dst := filepath.Join(targetDir, filepath.FromSlash(rel))
		st, err := os.Lstat(dst)
		switch {
		case errors.Is(err, fs.ErrNotExist):
			if err := anlegenPointer(dst, f.ziel, rel); err != nil {
				return err
			}
		case err != nil:
			return fmt.Errorf("%s pruefen: %w", rel, err)
		case st.Mode()&fs.ModeSymlink != 0:
			steht, err := os.Readlink(dst)
			if err != nil {
				return fmt.Errorf("%s lesen: %w", rel, err)
			}
			if steht != f.ziel {
				if err := ersetzePointer(dst, f.ziel, rel); err != nil {
					return err
				}
			}
		case st.Mode().IsRegular():
			continue
		default:
			return fmt.Errorf("%s ist weder Datei noch Pointer (%s) — die Bestands-Behandlung sagt diesen Eintrag nicht, der Lauf bricht ab", rel, st.Mode())
		}
	}
	return nil
}

// anlegenPointer legt einen fehlenden Pointer an. MkdirAll gilt den Elternpfad — der
// .claude/rules/ Zweig einer Ziel-Wurzel entsteht mit dieser Emission und nur mit ihr.
func anlegenPointer(dst, ziel, rel string) error {
	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		return fmt.Errorf("%s anlegen: %w", filepath.Dir(rel), err)
	}
	if err := os.Symlink(ziel, dst); err != nil {
		return fmt.Errorf("%s anlegen: %w", rel, err)
	}
	return nil
}

// ersetzePointer nimmt einen bestehenden Pointer mit anderem Zielpfad und setzt ihn auf
// die aktuelle Fassung um. Der Zielpfad steht dabei als Konstante dieses Emits; ein
// adopter-eigenes Ziel an demselben Namen, das hier ankaeme, wuerde ueberschrieben —
// die Bestands-Behandlung unterscheidet Pointer nicht nach ihrem Inhaber, der exakte
// Name ist die Grenze.
func ersetzePointer(dst, ziel, rel string) error {
	if err := os.Remove(dst); err != nil {
		return fmt.Errorf("%s umsetzen: %w", rel, err)
	}
	return anlegenPointer(dst, ziel, rel)
}

// Package ausnahmegrund haelt die Begruendung neben einem Ausnahme-Eintrag einer
// d-check-Konfiguration gegen den Gegenstand, den der Eintrag stumm schaltet (LH-QA-01): jeder
// Baum, in dem der Schluessel eine Markdown-Datei trifft, steht in der Begruendung.
//
// Ausnahme-Eintraege sind die Werte unter `scan.ignore`, unter jedem `exempt-paths`, die
// `in`-Werte des Top-Level-Blocks `ignore-refs` (Klasse Glob: der Schluessel trifft die Dateien,
// auf die sein Muster passt) und die Werte unter `codepaths.ignore-refs` (Klasse Zitat: der
// Schluessel trifft jede Datei im Pruefbereich, die den Pfad in Inline-Code nennt).
//
// Ein Baum ist das Verzeichnis einer getroffenen Datei, gekuerzt auf eine Mindest-Tiefe (tiefe);
// genannt ist er, wenn die Begruendung diesen Pfad mit abschliessendem `/` enthaelt — eine
// tiefere Nennung enthaelt ihn und zaehlt mit. Liegt die Datei flacher, ist es ihr ganzes
// Verzeichnis, an der Wurzel ihr Name.
// Die Begruendung eines Eintrags ist sein Wert plus die Kommentarzeilen direkt ueber ihm; hat er
// keine, die Kommentare seines Top-Level-Blocks bis zu seiner Zeile samt der Gruppe direkt ueber
// dem Block. Ein Zitat-Eintrag braucht die eigene Gruppe.
//
// GRENZE: geprueft wird, ob die Begruendung die Baeume NENNT, nicht ob sie stimmt; eine
// Nennung in einem Satz, der etwas anderes sagt, zaehlt mit. Ein Glob-Wert ohne Platzhalter
// nennt seinen Gegenstand selbst und hat keinen weiteren. `exempt-targets`, `exclude-sections`,
// `exempt-pattern` und die `refs`-Seite des Top-Level-Blocks `ignore-refs` sind nicht erfasst.
// Die Zitat-Suche ist ein Teilstring-Vergleich hinter einem Backtick, nicht der Pfad-Parser des
// Werkzeugs. Gelesen wird die Schreibform dieser Konfigurationen (Flow-Liste auf einer Zeile,
// Block-Liste mit `- `); eine andere gleichwertige YAML-Form erkennt der Parser nicht.
package ausnahmegrund

import (
	"io/fs"
	"os"
	"path"
	"path/filepath"
	"strconv"
	"regexp"
	"sort"
	"strings"
)

// Klasse sagt, wie ein Eintrag seinen Gegenstand trifft.
type Klasse int

const (
	// Glob trifft die Dateien, auf die das Muster passt.
	Glob Klasse = iota
	// Zitat trifft die Dateien, die den Pfad in Inline-Code nennen.
	Zitat
)

// Eintrag ist ein Ausnahme-Eintrag samt seiner Begruendung.
type Eintrag struct {
	Schluessel  string // z. B. "scan.ignore", "codepaths.ignore-refs"
	Wert        string
	Zeile       int // 1-basiert
	Klasse      Klasse
	Begruendung string
	EigeneGrp   bool // die Begruendung stammt aus der Gruppe direkt ueber dem Eintrag
}

var (
	reTop       = regexp.MustCompile(`^([A-Za-z][\w-]*):`)
	reFlow      = regexp.MustCompile(`^\s*(?:- )?(ignore|exempt-paths):\s*\[([^\]]*)\]`)
	reBlockKopf = regexp.MustCompile(`^(\s*)(?:- )?(exempt-paths|ignore-refs):\s*(#.*)?$`)
	reItem      = regexp.MustCompile(`^(\s*)- (?:in:\s*)?"?([^"#\s]+)"?\s*(#.*)?$`)
	reInItem    = regexp.MustCompile(`^\s+- in:\s*"?([^"#\s]+)"?`)
)

func kommentar(l string) bool { return strings.HasPrefix(strings.TrimSpace(l), "#") }

// inline liefert den Kommentar hinter einem Wert (ohne Anfuehrungszeichen-Kontext: die
// Konfigurationen tragen kein # in einem Wert).
func inline(l string) string {
	if i := strings.Index(l, " #"); i >= 0 && !kommentar(l) {
		return l[i:]
	}
	return ""
}

// gruppe liefert die zusammenhaengenden Kommentarzeilen direkt ueber Zeile i.
func gruppe(zeilen []string, i int) string {
	var g []string
	for j := i - 1; j >= 0 && kommentar(zeilen[j]); j-- {
		g = append([]string{zeilen[j]}, g...)
	}
	return strings.Join(g, "\n")
}

// Eintraege liest die Ausnahme-Eintraege einer d-check-Konfiguration.
func Eintraege(yml string) []Eintrag {
	zeilen := strings.Split(yml, "\n")
	var out []Eintrag
	top, topZeile := "", 0
	blockKey, blockIndent := "", -1
	for i, l := range zeilen {
		if kommentar(l) || strings.TrimSpace(l) == "" {
			continue
		}
		if m := reTop.FindStringSubmatch(l); m != nil {
			top, topZeile = m[1], i
			blockKey, blockIndent = "", -1
		}
		abschnitt := func() string {
			var t []string
			if g := gruppe(zeilen, topZeile); g != "" {
				t = append(t, g)
			}
			for j := topZeile; j <= i; j++ {
				if kommentar(zeilen[j]) {
					t = append(t, zeilen[j])
				} else if c := inline(zeilen[j]); c != "" {
					t = append(t, c)
				}
			}
			return strings.Join(t, "\n")
		}
		if m := reFlow.FindStringSubmatch(l); m != nil {
			if m[1] == "ignore" && top != "scan" {
				continue
			}
			for _, w := range strings.Split(m[2], ",") {
				w = strings.Trim(strings.TrimSpace(w), `"'`)
				if w == "" {
					continue
				}
				out = append(out, Eintrag{Schluessel: top + "." + m[1], Wert: w, Zeile: i + 1,
					Klasse: Glob, Begruendung: abschnitt() + "\n" + w})
			}
			continue
		}
		if top == "ignore-refs" {
			if m := reInItem.FindStringSubmatch(l); m != nil {
				out = append(out, eintrag(zeilen, i, "ignore-refs.in", m[1], Glob, abschnitt))
			}
			continue
		}
		if m := reBlockKopf.FindStringSubmatch(l); m != nil && reTop.FindStringSubmatch(l) == nil {
			blockKey, blockIndent = m[2], len(m[1])
			continue
		}
		if blockKey != "" {
			m := reItem.FindStringSubmatch(l)
			if m == nil || len(m[1]) < blockIndent {
				blockKey, blockIndent = "", -1
				continue
			}
			switch {
			case blockKey == "exempt-paths":
				out = append(out, eintrag(zeilen, i, top+".exempt-paths", m[2], Glob, abschnitt))
			case blockKey == "ignore-refs" && top == "codepaths":
				out = append(out, eintrag(zeilen, i, "codepaths.ignore-refs", m[2], Zitat, abschnitt))
			}
		}
	}
	return out
}

func eintrag(zeilen []string, i int, key, wert string, k Klasse, abschnitt func() string) Eintrag {
	e := Eintrag{Schluessel: key, Wert: wert, Zeile: i + 1, Klasse: k}
	if g := gruppe(zeilen, i); g != "" {
		e.Begruendung, e.EigeneGrp = g+"\n"+wert, true
	} else {
		e.Begruendung = abschnitt() + "\n" + wert
	}
	return e
}

// Passt sagt, ob das d-check-Glob muster auf den Schraegstrich-Pfad p passt: `**` steht fuer
// beliebig viele Segmente (auch keines), sonst gilt path.Match je Segment.
func Passt(muster, p string) bool {
	return passt(strings.Split(muster, "/"), strings.Split(p, "/"))
}

func passt(m, p []string) bool {
	if len(m) == 0 {
		return len(p) == 0
	}
	if m[0] == "**" {
		for k := 0; k <= len(p); k++ {
			if passt(m[1:], p[k:]) {
				return true
			}
		}
		return false
	}
	if len(p) == 0 {
		return false
	}
	ok, err := path.Match(m[0], p[0])
	return err == nil && ok && passt(m[1:], p[1:])
}

func platzhalter(s string) bool { return strings.ContainsAny(s, "*?[") }

// Treffer liefert die Dateien aus dateien (Pfad -> Inhalt, nur Markdown), die der Eintrag
// trifft. pruefbereich filtert die Kandidaten eines Zitat-Eintrags.
func Treffer(e Eintrag, dateien map[string]string, pruefbereich func(string) bool) []string {
	var t []string
	for p, inhalt := range dateien {
		switch e.Klasse {
		case Glob:
			if Passt(e.Wert, p) {
				t = append(t, p)
			}
		case Zitat:
			if pruefbereich(p) && strings.Contains(inhalt, "`"+e.Wert) {
				t = append(t, p)
			}
		}
	}
	sort.Strings(t)
	return t
}

// zitatTiefe ist die Mindest-Tiefe, in der ein Zitat-Eintrag den Baum eines Treffers nennt: die
// Tiefe der Lifecycle-Verzeichnisse unter docs/plan/planning/, der tiefsten Baum-Klasse dieses
// Layouts. Eine Nennung von docs/plan/planning/done/ deckt damit keinen Treffer in open/.
const zitatTiefe = 4

// tiefe liefert die Mindest-Tiefe der Nennung: bei einem Glob die Tiefe seines woertlichen
// Praefixes, mindestens zwei Segmente — `docs/reviews/**` nennt seinen Baum selbst,
// `.harness/**` verlangt jeden getroffenen `.harness/<baum>/`, ein Glob ab der Wurzel jeden
// getroffenen Baum zweiter Ebene —, bei einem Zitat zitatTiefe.
func tiefe(e Eintrag) int {
	if e.Klasse == Zitat {
		return zitatTiefe
	}
	n := 0
	for _, s := range strings.Split(e.Wert, "/") {
		if platzhalter(s) {
			break
		}
		n++
	}
	if n < 2 {
		return 2
	}
	return n
}

// name liefert den Pfad, der den Baum der Datei p in Tiefe t nennt (mit abschliessendem `/`;
// an der Wurzel den Dateinamen); liegt p flacher, das ganze Verzeichnis.
func name(p string, t int) string {
	seg := strings.Split(p, "/")
	dir := seg[:len(seg)-1]
	if len(dir) == 0 {
		return p
	}
	if t > len(dir) {
		t = len(dir)
	}
	return strings.Join(dir[:t], "/") + "/"
}

// genannt sagt, ob die Begruendung den Baum der Datei p in Tiefe t nennt. Eine tiefere Nennung
// enthaelt die flachere und zaehlt mit.
func genannt(begruendung, p string, t int) bool {
	return strings.Contains(begruendung, name(p, t))
}

// Befunde liefert je Eintrag die Baeume, die seine Begruendung nicht nennt, als lesbare Zeilen.
func Befunde(eintraege []Eintrag, dateien map[string]string, pruefbereich func(string) bool) []string {
	var b []string
	for _, e := range eintraege {
		if e.Klasse == Glob && !platzhalter(e.Wert) {
			continue
		}
		if e.Klasse == Zitat && !e.EigeneGrp {
			b = append(b, e.Schluessel+" "+e.Wert+" (Zeile "+strconv.Itoa(e.Zeile)+
				"): kein eigener Kommentar direkt ueber dem Eintrag — ein referenz-weiter Eintrag traegt seine Begruendung selbst")
			continue
		}
		fehlt := map[string]string{}
		for _, p := range Treffer(e, dateien, pruefbereich) {
			if !genannt(e.Begruendung, p, tiefe(e)) {
				d := name(p, tiefe(e))
				if _, ok := fehlt[d]; !ok {
					fehlt[d] = p
				}
			}
		}
		dirs := make([]string, 0, len(fehlt))
		for d := range fehlt {
			dirs = append(dirs, d)
		}
		sort.Strings(dirs)
		for _, d := range dirs {
			b = append(b, e.Schluessel+" "+e.Wert+" (Zeile "+strconv.Itoa(e.Zeile)+"): die Begruendung nennt "+d+
				" nicht — der Schluessel trifft dort "+fehlt[d])
		}
	}
	return b
}

// Pruefbereich nimmt aus, was scan.ignore und codepaths.exempt-paths derselben Konfiguration
// ausnehmen: dort sieht codepaths keine Referenz, und ein Zitat dort ist kein Gegenstand.
func Pruefbereich(eintraege []Eintrag) func(string) bool {
	return func(p string) bool {
		for _, e := range eintraege {
			if (e.Schluessel == "scan.ignore" || e.Schluessel == "codepaths.exempt-paths") && Passt(e.Wert, p) {
				return false
			}
		}
		return true
	}
}

// MarkdownBaum liest jede Markdown-Datei unter root (Schraegstrich-Pfade relativ zu root);
// .git/ und symbolische Links bleiben aussen (ein Link ist eine Adresse, keine eigene Datei).
func MarkdownBaum(root string) (map[string]string, error) {
	out := map[string]string{}
	err := filepath.WalkDir(root, func(p string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() && d.Name() == ".git" {
			return filepath.SkipDir
		}
		if d.IsDir() || d.Type()&fs.ModeSymlink != 0 || !strings.HasSuffix(p, ".md") {
			return nil
		}
		b, err := os.ReadFile(p)
		if err != nil {
			return err
		}
		rel, err := filepath.Rel(root, p)
		if err != nil {
			return err
		}
		out[filepath.ToSlash(rel)] = string(b)
		return nil
	})
	return out, err
}


package gen_test

import (
	"errors"
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/gen"
)

// Gemeinsame Pruefungen der Sprach-Skelette mit einem Dockerfile-Stage-Fragment:
// je Sprache laufen dieselben Eigenschaften, nur Namen und Werte unterscheiden sich — ein
// Helfer statt eines Klons je Sprache.

// generateWith generiert das Skelett der Sprache mit einer expliziten Toolchain-Version.
func generateWith(t *testing.T, lang, version string) string {
	t.Helper()
	dir := t.TempDir()
	if err := gen.Generate(dir, lang, version); err != nil {
		t.Fatalf("Generate(%s, %q): %v", lang, version, err)
	}
	return dir
}

// fragmentFassungen liefert das Code-Gate-Fragment einer Sprache in seinen drei Fassungen
// (Root, Subdir <subdir>, gemischter Root), je unter dem Namen der Fassung.
func fragmentFassungen(t *testing.T, lang, subdir, version string) map[string]string {
	t.Helper()
	out := map[string]string{}
	for name, pfad := range map[string]string{"root": ".", "subdir": subdir} {
		mk, err := gen.CodeGateFragment(lang, pfad, version)
		if err != nil {
			t.Fatalf("CodeGateFragment(%s, %s): %v", lang, pfad, err)
		}
		out[name] = mk
	}
	mixed, err := gen.CodeGateFragmentMixed(lang, ".", version)
	if err != nil {
		t.Fatalf("CodeGateFragmentMixed(%s, .): %v", lang, err)
	}
	out["gemischt"] = mixed
	return out
}

// assertDeterministic haelt LH-QA-02: zwei Laeufe mit gleicher Version liefern
// byte-identische Dateien.
func assertDeterministic(t *testing.T, lang, version string) {
	t.Helper()
	d1, d2 := generateWith(t, lang, version), generateWith(t, lang, version)
	rels := walkRel(t, d1)
	if strings.Join(rels, ",") != strings.Join(walkRel(t, d2), ",") {
		t.Fatalf("zwei %s-Laeufe erzeugten verschiedene Datei-Saetze", lang)
	}
	for _, rel := range rels {
		if mustRead(t, filepath.Join(d1, filepath.FromSlash(rel))) != mustRead(t, filepath.Join(d2, filepath.FromSlash(rel))) {
			t.Errorf("%s unterscheidet sich zwischen zwei %s-Laeufen", rel, lang)
		}
	}
}

// assertTargetsMatchStages (LH-QA-01): jedes `docker build --target <X>` in jeder Fassung des
// Fragments hat eine gleichnamige Dockerfile-Stage `AS <X>`, und die drei Gate-Ziele
// test/lint/build sind jeweils gerufen.
func assertTargetsMatchStages(t *testing.T, lang, dockerfile string, fassungen map[string]string) {
	t.Helper()
	stages := map[string]bool{}
	for _, m := range regexp.MustCompile(`\bAS (\w+)`).FindAllStringSubmatch(dockerfile, -1) {
		stages[m[1]] = true
	}
	for name, mk := range fassungen {
		gerufen := map[string]bool{}
		for _, m := range regexp.MustCompile(`--target (\w+)`).FindAllStringSubmatch(mk, -1) {
			gerufen[m[1]] = true
			if !stages[m[1]] {
				t.Errorf("%s-Fragment (%s) ruft `--target %s`, aber Dockerfile hat keine Stage `AS %s`", lang, name, m[1], m[1])
			}
		}
		for _, ziel := range []string{"test", "lint", "build"} {
			if !gerufen[ziel] {
				t.Errorf("%s-Fragment (%s) ruft `--target %s` nicht — das Gate fehlt", lang, name, ziel)
			}
		}
	}
}

// assertRootUndSubdir: die Root-Fassung haengt lint/build/test an GATE_CHECKS und baut im
// Root-Kontext; die Subdir-Fassung (Modul <modul>, Kontext <pfad>) traegt modul-scoped Targets
// und keine unscoped; die gemischte Fassung traegt die gemeinsame Form.
func assertRootUndSubdir(t *testing.T, lang, modul, pfad string, fassungen map[string]string) {
	t.Helper()
	erwartet := map[string][]string{
		"root":   {"GATE_CHECKS += lint build test", "--target test -t $(IMAGE):test ."},
		"subdir": {"GATE_CHECKS += lint-" + modul + " build-" + modul + " test-" + modul, "--target test -t " + modul + ":test " + pfad},
	}
	for name, wants := range erwartet {
		for _, want := range wants {
			if !strings.Contains(fassungen[name], want) {
				t.Errorf("%s-Fragment (%s) enthaelt %q nicht:\n%s", lang, name, want, fassungen[name])
			}
		}
	}
	for _, forbidden := range []string{"\ntest:", "\nlint:", "\nbuild:"} {
		if strings.Contains(fassungen["subdir"], forbidden) {
			t.Errorf("modul-scoped %s-Fragment traegt unscoped Target %q:\n%s", lang, forbidden, fassungen["subdir"])
		}
	}
	mixedFragmentFest(t, fassungen["gemischt"], lang, []string{"--target test -t " + lang + ":test ."})
}

// assertTagVariable: der Versions-Default steht in allen Fassungen unter <variable> und unter
// keinem der Namen <fremde>, die ein Fragment einer anderen Sprache im selben Ziel setzt — mit
// `?=` gilt sonst der erste gelesene Wert fuer beide Sprachen.
func assertTagVariable(t *testing.T, lang, variable string, fremde []string, fassungen map[string]string, wert string) {
	t.Helper()
	setzt := regexp.MustCompile(`(?m)^` + regexp.QuoteMeta(variable) + ` \?= (\S+)$`)
	for name, mk := range fassungen {
		for _, f := range fremde {
			if regexp.MustCompile(`(?m)^` + regexp.QuoteMeta(f) + `\b`).MatchString(mk) {
				t.Errorf("%s-Fragment (%s) setzt %s — der Name gehoert dem Fragment einer anderen Sprache:\n%s", lang, name, f, mk)
			}
		}
		if m := setzt.FindStringSubmatch(mk); m == nil || m[1] != wert {
			t.Errorf("%s-Fragment (%s): %s-Default nicht %s:\n%s", lang, name, variable, wert, mk)
		}
	}
}

// assertNurFlat: hexslice und hexagonal rendert der Renderer der Sprache nicht — Exit-2-Klasse
// mit der Liste der Sprache (flat), ohne Artefakte, kein Geruest-only-Skelett.
func assertNurFlat(t *testing.T, lang, version string) {
	t.Helper()
	for _, arch := range []string{"hexslice", "hexagonal"} {
		dir := t.TempDir()
		err := gen.GenerateArch(dir, lang, version, arch)
		var uae *gen.UnknownArchError
		if !errors.As(err, &uae) {
			t.Fatalf("erwartete *UnknownArchError fuer %s+%s, got %v", lang, arch, err)
		}
		if strings.Join(uae.Available, ",") != "flat" {
			t.Errorf("Available = %v, want [flat]", uae.Available)
		}
		if rels := walkRel(t, dir); len(rels) != 0 {
			t.Errorf("abgelehnte Kombination %s+%s hat Artefakte geschrieben: %v", lang, arch, rels)
		}
	}
}

// assertPaketGleichVerzeichnis: jede <ext>-Datei unter src/<set>/<lang>/ in dir deklariert
// genau das Paket ihres Verzeichnisses (`package a.b<abschluss>`; abschluss ist "" fuer Kotlin,
// ";" fuer Java). a-check loest einen Import ueber den PFAD auf; ein Paket ausserhalb seines
// Verzeichnisses entginge dem Arch-Gate.
func assertPaketGleichVerzeichnis(t *testing.T, dir, lang, ext, abschluss string) {
	t.Helper()
	pkgRe := regexp.MustCompile(`(?m)^package ([a-z.]+)` + regexp.QuoteMeta(abschluss) + `$`)
	n := 0
	for _, rel := range walkRel(t, dir) {
		if !strings.HasSuffix(rel, ext) {
			continue
		}
		n++
		parts := strings.SplitN(rel, "/", 4) // src/<set>/<lang>/<paket-pfad>/<Datei>
		if len(parts) != 4 || parts[0] != "src" || parts[2] != lang {
			t.Errorf("%s liegt nicht unter src/<set>/%s/", rel, lang)
			continue
		}
		want := strings.ReplaceAll(filepath.ToSlash(filepath.Dir(parts[3])), "/", ".")
		m := pkgRe.FindStringSubmatch(mustRead(t, filepath.Join(dir, filepath.FromSlash(rel))))
		if m == nil {
			t.Errorf("%s traegt keine package-Zeile", rel)
		} else if m[1] != want {
			t.Errorf("%s deklariert package %s, das Verzeichnis verlangt %s", rel, m[1], want)
		}
	}
	if n == 0 {
		t.Fatalf("keine %s-Datei im Skelett", ext)
	}
}

// assertGlobsMatchSkeleton: jede <ext>-Produktionsdatei in dir ausser Tests (src/test/) und
// Composition Root (mainRel) faellt unter den Schicht-Glob, den want fuer sie nennt; der
// spezifischste Glob bestimmt die Schicht, und jeder Glob ist fuer mindestens eine Datei der
// spezifischste (ein Glob ohne Datei ist der stille Rest, aus dem ein Gate ueber leerem
// Bereich wird, LH-QA-01). want steht ausgeschrieben, nicht aus der Config abgeleitet.
func assertGlobsMatchSkeleton(t *testing.T, cfg, dir, ext, mainRel string, want map[string]string, ausgenommen ...func(rel string) bool) {
	t.Helper()
	globs := archGlobs(t, cfg)
	hits := map[string]int{}
	seen := map[string]bool{}
	for _, rel := range walkRel(t, dir) {
		if !strings.HasSuffix(rel, ext) || strings.HasPrefix(rel, "src/test/") || rel == mainRel || ausgenommenVon(rel, ausgenommen) {
			continue // exclude bzw. composition_root
		}
		seen[rel] = true
		layer, glob := mostSpecific(globs, rel)
		hits[glob]++
		switch {
		case layer == "":
			t.Errorf("%s faellt unter KEINE Schicht (Loch im Pruefbereich)", rel)
		case want[rel] == "":
			t.Errorf("%s ist neu im Skelett, aber in der Erwartung nicht gefuehrt", rel)
		case layer != want[rel]:
			t.Errorf("%s faellt unter Schicht %q, want %q", rel, layer, want[rel])
		}
	}
	for rel := range want {
		if !seen[rel] {
			t.Errorf("erwartete Skelett-Datei %s fehlt (Rollen-Pfad gewandert?)", rel)
		}
	}
	for layer, gs := range globs {
		for _, g := range gs {
			if hits[g] == 0 {
				t.Errorf("Schicht %s: Glob %q ist fuer keine Datei der spezifischste (LH-QA-01)", layer, g)
			}
		}
	}
}

// ausgenommenVon sagt, ob eine der Ausnahme-Funktionen die Datei rel aus dem Pruefbereich
// nimmt (Tests ausserhalb von src/test/, leere Paket-Marker).
func ausgenommenVon(rel string, fs []func(rel string) bool) bool {
	for _, f := range fs {
		if f(rel) {
			return true
		}
	}
	return false
}

// archConfigResolution zieht languages-Glob, mode, roots und package_base der Sprache lang aus
// der .a-check.yml. Jeder Schluessel wird einzeln und woertlich gelesen: ein verfaelschter Wert
// faerbt genau die Aussage, die er traegt.
func archConfigResolution(t *testing.T, cfg, lang string) (langGlob, mode string, roots []string, base string) {
	t.Helper()
	lm := regexp.MustCompile(`(?m)^languages:\n  ` + lang + `: \["([^"]+)"\]$`).FindStringSubmatch(cfg)
	i := strings.Index(cfg, "\nresolution:\n  "+lang+":\n")
	if lm == nil || i < 0 {
		t.Fatalf("kein languages-%s-Eintrag oder kein resolution-Block %s in der Config:\n%s", lang, lang, cfg)
	}
	block := cfg[i:]
	mm := regexp.MustCompile(`(?m)^    mode: (\S+)$`).FindStringSubmatch(block)
	rm := regexp.MustCompile(`(?m)^    roots: \[((?:"[^"]+"(?:, )?)+)\]$`).FindStringSubmatch(block)
	bm := regexp.MustCompile(`(?m)^    package_base: "([^"]+)"$`).FindStringSubmatch(block)
	if mm == nil || rm == nil || bm == nil {
		t.Fatalf("resolution-Block %s ohne mode, roots oder package_base:\n%s", lang, block)
	}
	for _, r := range regexp.MustCompile(`"([^"]+)"`).FindAllStringSubmatch(rm[1], -1) {
		roots = append(roots, r[1])
	}
	return lm[1], mm[1], roots, bm[1]
}

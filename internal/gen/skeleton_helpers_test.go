package gen_test

import (
	"errors"
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/gen"
)

// Gemeinsame Pruefungen der Sprach-Skelette mit einem Dockerfile-Stage-Fragment (java, python):
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

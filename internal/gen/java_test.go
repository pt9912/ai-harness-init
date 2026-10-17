package gen_test

import (
	"errors"
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"github.com/pt9912/ai-harness-init/internal/gen"
)

// genJavaWith generiert das Java-Skelett mit einem expliziten gradle-Tag.
func genJavaWith(t *testing.T, version string) string {
	t.Helper()
	dir := t.TempDir()
	if err := gen.Generate(dir, "java", version); err != nil {
		t.Fatalf("Generate(java, %q): %v", version, err)
	}
	return dir
}

// TestGenerate_JavaProfile: --lang java erzeugt GENAU den erwarteten Skelett-Satz
// (LH-FA-04, ADR-0094 Festlegung 1–3) — Einzelmodul ohne Wrapper, Checkstyle-Config am
// Default-Pfad des Gradle-Plugins, Dockerfile, Main und Test; jede .java-Datei deklariert
// das Paket ihres Verzeichnisses unter src/<set>/java. Nicht mehr, nicht weniger.
func TestGenerate_JavaProfile(t *testing.T) {
	dir := genJavaWith(t, gen.DefaultJavaVersion)
	got := walkRel(t, dir)
	want := []string{
		"Dockerfile", "build.gradle.kts", "config/checkstyle/checkstyle.xml", "settings.gradle.kts",
		"src/main/java/app/Main.java", "src/test/java/app/MainTest.java",
	}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("erzeugter Datei-Satz = %v\nwant %v", got, want)
	}
	if s := mustRead(t, filepath.Join(dir, "settings.gradle.kts")); strings.Contains(s, "include") {
		t.Errorf("settings.gradle.kts traegt ein include — ADR-0094 Festlegung 1 verlangt ein Modul:\n%s", s)
	}
	bg := mustRead(t, filepath.Join(dir, "build.gradle.kts"))
	for _, want := range []string{"    java\n", "    application\n", "    checkstyle\n",
		`platform("org.junit:junit-bom:`, `testRuntimeOnly("org.junit.platform:junit-platform-launcher")`, "useJUnitPlatform()"} {
		if !strings.Contains(bg, want) {
			t.Errorf("build.gradle.kts enthaelt %q nicht:\n%s", want, bg)
		}
	}
	pkgRe := regexp.MustCompile(`(?m)^package ([a-z.]+);$`)
	n := 0
	for _, rel := range got {
		if !strings.HasSuffix(rel, ".java") {
			continue
		}
		n++
		parts := strings.SplitN(rel, "/", 4) // src/<set>/java/<paket-pfad>/<Datei>.java
		if len(parts) != 4 || parts[0] != "src" || parts[2] != "java" {
			t.Errorf("%s liegt nicht unter src/<set>/java/", rel)
			continue
		}
		wantPkg := strings.ReplaceAll(filepath.ToSlash(filepath.Dir(parts[3])), "/", ".")
		m := pkgRe.FindStringSubmatch(mustRead(t, filepath.Join(dir, filepath.FromSlash(rel))))
		if m == nil {
			t.Errorf("%s traegt keine package-Zeile", rel)
		} else if m[1] != wantPkg {
			t.Errorf("%s deklariert package %s, das Verzeichnis verlangt %s", rel, m[1], wantPkg)
		}
	}
	if n != 2 {
		t.Errorf("%d .java-Dateien im flat-Skelett, want 2", n)
	}
	assertFileContains(t, filepath.Join(dir, "Dockerfile"), "FROM gradle:${GRADLE_TAG} AS toolchain")
}

// TestGenerate_JavaDeterministic haelt LH-QA-02 fuer java: zwei Laeufe mit gleichem Tag
// liefern byte-identische Dateien.
func TestGenerate_JavaDeterministic(t *testing.T) {
	d1, d2 := genJavaWith(t, gen.DefaultJavaVersion), genJavaWith(t, gen.DefaultJavaVersion)
	rels := walkRel(t, d1)
	if strings.Join(rels, ",") != strings.Join(walkRel(t, d2), ",") {
		t.Fatal("zwei java-Laeufe erzeugten verschiedene Datei-Saetze")
	}
	for _, rel := range rels {
		if mustRead(t, filepath.Join(d1, filepath.FromSlash(rel))) != mustRead(t, filepath.Join(d2, filepath.FromSlash(rel))) {
			t.Errorf("%s unterscheidet sich zwischen zwei java-Laeufen", rel)
		}
	}
}

// TestJavaLintConfig_TraegtUnusedImportsUndMaxWarnings (ADR-0094 Festlegung 3): gebunden
// ist, dass UnusedImports als Modul des TreeWalkers in der Checkstyle-Config steht, dass
// build.gradle.kts im checkstyle-Block maxWarnings = 0 setzt und dass die Config am
// Default-Pfad des Plugins liegt (der Block traegt keine config-Zeile). Eine Config ohne
// UnusedImports liesse den Lint-Fall der Fitness Function ungeprueft, statt zu brechen.
func TestJavaLintConfig_TraegtUnusedImportsUndMaxWarnings(t *testing.T) {
	dir := genJavaWith(t, gen.DefaultJavaVersion)
	cfg := mustRead(t, filepath.Join(dir, "config", "checkstyle", "checkstyle.xml"))
	// Kommentar-Text ist kein Modul: nur die <module>-Zeilen zaehlen.
	ohneKommentar := regexp.MustCompile(`(?s)<!--.*?-->`).ReplaceAllString(cfg, "")
	walker := firstSub(t, regexp.MustCompile(`(?s)<module name="TreeWalker">(.*)</module>\s*</module>`), ohneKommentar)
	if !strings.Contains(walker, `<module name="UnusedImports"/>`) {
		t.Errorf("TreeWalker fuehrt UnusedImports nicht:\n%s", cfg)
	}
	if !strings.Contains(ohneKommentar, `<property name="severity" value="error"/>`) {
		t.Errorf("Checker setzt Severity error nicht:\n%s", cfg)
	}
	bg := mustRead(t, filepath.Join(dir, "build.gradle.kts"))
	block := firstSub(t, regexp.MustCompile(`(?s)\ncheckstyle \{\n(.*?)\n\}`), bg)
	if !regexp.MustCompile(`(?m)^    maxWarnings = 0$`).MatchString(block) {
		t.Errorf("checkstyle-Block setzt maxWarnings = 0 nicht:\n%s", block)
	}
	if !regexp.MustCompile(`(?m)^    toolVersion = "\d+\.\d+\.\d+"$`).MatchString(block) {
		t.Errorf("checkstyle-Block pinnt toolVersion nicht per Version:\n%s", block)
	}
	if strings.Contains(block, "config") {
		t.Errorf("checkstyle-Block traegt eine config-Zeile — die Config liegt am Default-Pfad:\n%s", block)
	}
}

// javaFragmente liefert das Java-Code-Gate-Fragment in seinen drei Fassungen (Root, Subdir
// apps/jv, gemischter Root), je unter dem Namen der Fassung.
func javaFragmente(t *testing.T, version string) map[string]string {
	t.Helper()
	out := map[string]string{}
	for name, pfad := range map[string]string{"root": ".", "subdir": "apps/jv"} {
		mk, err := gen.CodeGateFragment("java", pfad, version)
		if err != nil {
			t.Fatalf("CodeGateFragment(java, %s): %v", pfad, err)
		}
		out[name] = mk
	}
	mixed, err := gen.CodeGateFragmentMixed("java", ".", version)
	if err != nil {
		t.Fatalf("CodeGateFragmentMixed(java, .): %v", err)
	}
	out["gemischt"] = mixed
	return out
}

// TestJavaCodeGateFragment_TargetsMatchStages ist der LH-QA-01-Anker fuer java (ADR-0094
// §Fitness Function): jedes `docker build --target <X>` im Fragment hat eine gleichnamige
// Dockerfile-Stage `AS <X>` — in allen drei Fassungen (Root, Subdir, gemischter Root) —, und
// die drei Gate-Ziele test/lint/build sind jeweils gerufen.
func TestJavaCodeGateFragment_TargetsMatchStages(t *testing.T) {
	df := mustRead(t, filepath.Join(genJavaWith(t, gen.DefaultJavaVersion), "Dockerfile"))
	stages := map[string]bool{}
	for _, m := range regexp.MustCompile(`\bAS (\w+)`).FindAllStringSubmatch(df, -1) {
		stages[m[1]] = true
	}
	for name, mk := range javaFragmente(t, gen.DefaultJavaVersion) {
		gerufen := map[string]bool{}
		for _, m := range regexp.MustCompile(`--target (\w+)`).FindAllStringSubmatch(mk, -1) {
			gerufen[m[1]] = true
			if !stages[m[1]] {
				t.Errorf("java-Fragment (%s) ruft `--target %s`, aber Dockerfile hat keine Stage `AS %s`", name, m[1], m[1])
			}
		}
		for _, ziel := range []string{"test", "lint", "build"} {
			if !gerufen[ziel] {
				t.Errorf("java-Fragment (%s) ruft `--target %s` nicht — das Gate fehlt", name, ziel)
			}
		}
	}
}

// TestJavaCodeGateFragment_RootUndSubdir: die Root-Fassung haengt lint/build/test an
// GATE_CHECKS und baut im Root-Kontext; die Subdir-Fassung traegt modul-scoped Targets und
// keine unscoped; die gemischte Fassung traegt die gemeinsame Form.
func TestJavaCodeGateFragment_RootUndSubdir(t *testing.T) {
	fassungen := javaFragmente(t, gen.DefaultJavaVersion)
	erwartet := map[string][]string{
		"root":   {"GATE_CHECKS += lint build test", "--target test -t $(IMAGE):test ."},
		"subdir": {"GATE_CHECKS += lint-apps-jv build-apps-jv test-apps-jv", "--target test -t apps-jv:test apps/jv"},
	}
	for name, wants := range erwartet {
		for _, want := range wants {
			if !strings.Contains(fassungen[name], want) {
				t.Errorf("java-Fragment (%s) enthaelt %q nicht:\n%s", name, want, fassungen[name])
			}
		}
	}
	for _, forbidden := range []string{"\ntest:", "\nlint:", "\nbuild:"} {
		if strings.Contains(fassungen["subdir"], forbidden) {
			t.Errorf("modul-scoped java-Fragment traegt unscoped Target %q:\n%s", forbidden, fassungen["subdir"])
		}
	}
	mixedFragmentFest(t, fassungen["gemischt"], "java", []string{"--target test -t java:test ."})
}

// TestJavaCodeGateFragment_EigeneTagVariable: der Versions-Default steht in allen drei
// Fassungen unter JAVA_GRADLE_TAG und nie unter GRADLE_TAG. Ein Kotlin-Fragment im selben
// Ziel setzt GRADLE_TAG mit `?=`; teilten sich beide den Namen, gaelte der erste gelesene
// Wert fuer beide Sprachen und SKEL_JAVA_VERSION waere kein eigener Knopf.
func TestJavaCodeGateFragment_EigeneTagVariable(t *testing.T) {
	for name, mk := range javaFragmente(t, "7.7.7-jdk21") {
		if got := firstSub(t, regexp.MustCompile(`(?m)^JAVA_GRADLE_TAG \?= (\S+)$`), mk); got != "7.7.7-jdk21" {
			t.Errorf("java-Fragment (%s): JAVA_GRADLE_TAG-Default = %q, want 7.7.7-jdk21", name, got)
		}
		if regexp.MustCompile(`(?m)^GRADLE_TAG\b`).MatchString(mk) {
			t.Errorf("java-Fragment (%s) setzt GRADLE_TAG — der Name gehoert dem Kotlin-Fragment:\n%s", name, mk)
		}
	}
}


// TestGenerate_JavaVersionThreaded: der uebergebene gradle-Tag faedelt ins Dockerfile-ARG,
// und DefaultVersion("java") liefert den Default dorthin — der Knopf SKEL_JAVA_VERSION ist am
// Generator verankert (ADR-0094 Festlegung 2). DefaultJavaVersion hat die Form <ver>-jdk<NN>.
func TestGenerate_JavaVersionThreaded(t *testing.T) {
	df := mustRead(t, filepath.Join(genJavaWith(t, "8.14.3-jdk21"), "Dockerfile"))
	if got := firstSub(t, regexp.MustCompile(`ARG GRADLE_TAG=(\S+)`), df); got != "8.14.3-jdk21" {
		t.Errorf("Dockerfile ARG GRADLE_TAG = %q, want 8.14.3-jdk21", got)
	}
	if !regexp.MustCompile(`^\d+\.\d+(\.\d+)?-jdk\d+$`).MatchString(gen.DefaultJavaVersion) {
		t.Errorf("DefaultJavaVersion = %q ist kein gradle-Tag der Form <ver>-jdk<NN> (ADR-0094 Festlegung 2)", gen.DefaultJavaVersion)
	}
	if got := mustRead(t, filepath.Join(genJavaWith(t, gen.DefaultVersion("java")), "Dockerfile")); !strings.Contains(got, "ARG GRADLE_TAG="+gen.DefaultJavaVersion+"\n") {
		t.Errorf("DefaultVersion(java) erreicht das Dockerfile nicht:\n%s", got)
	}
}

// TestGenerateArch_JavaNurFlat (ADR-0094 Festlegung 4): hexslice und hexagonal rendert der
// Java-Renderer nicht — Exit-2-Klasse mit der Liste der Sprache (flat), ohne Artefakte, kein
// Geruest-only-Skelett. hexslice steht erst in langArchs, wenn sein Renderer es rendert.
func TestGenerateArch_JavaNurFlat(t *testing.T) {
	for _, arch := range []string{"hexslice", "hexagonal"} {
		dir := t.TempDir()
		err := gen.GenerateArch(dir, "java", gen.DefaultJavaVersion, arch)
		var uae *gen.UnknownArchError
		if !errors.As(err, &uae) {
			t.Fatalf("erwartete *UnknownArchError fuer java+%s, got %v", arch, err)
		}
		if strings.Join(uae.Available, ",") != "flat" {
			t.Errorf("Available = %v, want [flat]", uae.Available)
		}
		if rels := walkRel(t, dir); len(rels) != 0 {
			t.Errorf("abgelehnte Kombination java+%s hat Artefakte geschrieben: %v", arch, rels)
		}
	}
}

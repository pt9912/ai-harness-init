package emit

import (
	"errors"
	"fmt"
	"sort"
	"strings"
)

// TraegerWert ist einer der drei Werte, die ein Regelblock des mitgelieferten
// Regelwerks in der Inventur traegt. Die Menge ist GESCHLOSSEN: sie sagt den Zustand
// des Ziel-Repos, nicht den Stand einer Entscheidung. Fuer einen Traeger, der
// beschlossen und nicht abgelegt ist, waere "Traeger kommt mit" eine Falschaussage;
// gegen die eine Richtung, die ein Sensor erreicht — eine behauptete Abwesenheit, die
// derselbe Lauf ablegt —, steht
// TestTraegerInventur_KeineZelleBehauptetEineAbwesenheitDieDerEmitWiderlegt.
type TraegerWert string

const (
	// TraegerKommtMit — die Mechanik oder Ziel-Form liegt im Ziel und ist dort benutzbar.
	TraegerKommtMit TraegerWert = "Träger kommt mit"
	// TraegerLiegtBei — der Träger ist da, hängt aber an keinem Trigger.
	TraegerLiegtBei TraegerWert = "liegt bei, nicht verdrahtet"
	// TraegerKommtNichtMit — mit Grund UND Dauer: permanenter Grund oder Auflösungs-Trigger.
	TraegerKommtNichtMit TraegerWert = "kommt nicht mit"
)

// InventurMessTag ist der Kurs-Stand, gegen den die Zuordnung der Inventur gemessen ist.
// Er steht im emittierten Block, weil die Tabelle Regelbloecke beim NAMEN nennt: ohne den
// Stand waere sie eine Aussage ohne Bezugspunkt, und der Adopter koennte die Drift nicht
// einmal erkennen (MR-033).
//
// FAIL-CLOSED an den Tag gekoppelt, den der Bootstrap fetcht:
// TestInventurMessTag_IstDerGefetchteStand haelt beide gegeneinander — ein Baseline-Sprung,
// der den Stand hier stehen laesst, faerbt rot statt einen falschen Mess-Tag auszuliefern.
const InventurMessTag = "v6.9.0"

// TraegerEintrag ist eine Zeile der Inventur.
//
// Modul ist der Dateiname im `regelwerk/`-Verzeichnis des Ziels — der Nenner, gegen den
// die Abdeckung gemessen wird. Abschnitt ist leer, wo der ganze Regelblock einen Wert
// traegt, und nennt den §-Abschnitt, wo ein Modul zwei Mechaniken mit verschiedenen
// Werten vorschreibt.
//
// Abwesend traegt NUR bei TraegerKommtNichtMit einen Wert: das Ziel-Pfad-PRAEFIX, unter
// dem ein Traeger dieser Klasse erschiene. Geprueft wird der Bestand unter dem Praefix,
// nicht ein geratener Dateiname — eine Abwesenheits-Stichprobe auf einen Namen, den der
// Emit nie schreibt, kann unter keiner Mutation rot werden (AGENTS.md §3.6).
type TraegerEintrag struct {
	Modul     string
	Abschnitt string
	Wert      TraegerWert
	Text      string
	Abwesend  string
}

// traegerInventur ist die Inventur selbst — je Regelblock des mitgelieferten Regelwerks
// mindestens eine Zeile mit genau einem der drei Werte.
//
// Die ZUORDNUNG ist ein Urteil und steht deshalb aufgeschrieben da, statt aus einem
// Muster zu fallen: der Nenner ist mechanisch (die `*.md` des `regelwerk/`-Verzeichnisses),
// die Frage "traegt das Ziel den Traeger dieses Blocks" ist es nicht.
//
// Die Datei-Namen wandern mit dem gepinnten Baseline-Stand. Kommt upstream ein Regelblock
// dazu oder faellt einer weg, faellt test/baum-inventur.bats — das ist der gewollte
// Ausgang, kein Fehlalarm.
func traegerInventur() []TraegerEintrag {
	return []TraegerEintrag{
		{Modul: "README.md", Wert: TraegerLiegtBei,
			Text: "Der Index des Regelwerks liegt im vendored Baum und wird bei Bedarf gelesen; ein Injektor, der ihn je Sitzung in den Kontext hebt, kommt nicht mit."},
		{Modul: "grundlagen-begriffe.md", Wert: TraegerLiegtBei,
			Text: "Begriffs-Definitionen ohne eigene Mechanik — der Text ist sein eigener Träger und hängt an keinem Trigger."},
		{Modul: "grundlagen-bootstrap.md", Wert: TraegerKommtMit,
			Text: "`harness/conventions.md` führt den Abschnitt *Modus-Deklaration pro Sub-Area*, in dem Sub-Area, Kürzel, Modus und Graduation deklariert werden."},
		{Modul: "grundlagen-durchsetzungsschicht.md", Wert: TraegerKommtMit,
			Text: "`.claude/hooks/pretooluse-command-guard.sh`, `.claude/hooks/stop-require-gates.sh`, `tools/harness/record-gates.sh`, `tools/harness/working-tree-hash.sh` und der Eintrag in `.claude/settings.json`."},
		{Modul: "grundlagen-harness-dateien.md", Wert: TraegerKommtMit,
			Text: "`AGENTS.md`, `harness/README.md` und `harness/conventions.md` liegen als ausgefüllte Dateien, nicht als Vorlagen."},
		{Modul: "grundlagen-klassifikation.md", Wert: TraegerLiegtBei,
			Text: "Die Einordnung von Sensoren und der Steering Loop sind Lesestoff; kein Artefakt des Ziels hängt daran."},
		{Modul: "grundlagen-referenz-richtung.md", Wert: TraegerKommtMit,
			Text: "Das Doku-Gate führt die Klasse `spec-straten` mit `direction: no-downward` in `.d-check.yml`; `make docs-check` fährt sie."},
		{Modul: "grundlagen-source-precedence.md", Wert: TraegerKommtMit,
			Text: "`harness/README.md` §Source precedence und der Kopf von `AGENTS.md` tragen die Rangfolge."},
		{Modul: "grundlagen-traceability.md", Wert: TraegerKommtMit,
			Text: "Die Prüfung `tools/harness/commit-msg-traceability.sh` liegt in jedem Lauf. Der Träger `.githooks/commit-msg`, der sie ruft, kommt nur an einem freien Pfad — sein Name gehört git, und führt das Repo dort schon einen eigenen Hook, bleibt der stehen und ruft die Prüfung nur, wenn er es selbst tut. Aktiviert wird der Träger durch `make hooks-install`; bis dahin liegt er unwirksam da."},
		{Modul: "modul-00-einfuehrung.md", Wert: TraegerLiegtBei,
			Text: "Einführung ohne eigene Mechanik — der Text ist sein eigener Träger und hängt an keinem Trigger."},
		{Modul: "modul-01-entwicklungszyklus.md", Wert: TraegerKommtMit,
			Text: "Die Ziel-Form des Moduls ist der Source-Precedence-Block, und er liegt ausgefüllt in `harness/README.md`."},
		{Modul: "modul-02-harness-bootstrap.md", Abschnitt: "§Gate-Fragment und vendored Baseline", Wert: TraegerKommtMit,
			Text: "`tools/harness/baseline-verify.sh` mit dem Fragment `harness/mk/baseline.mk` hängt `baseline-verify` an die Gate-Kette; das Doku-Gate-Fragment liegt daneben."},
		{Modul: "modul-02-harness-bootstrap.md", Abschnitt: "§Freshness-Audit der vendored Baseline", Wert: TraegerKommtNichtMit,
			Text: "Kein Sensor prüft, ob upstream ein neuerer Stand erschienen ist — er bräuchte Netzzugriff über `bash`, `git` und `docker` hinaus. Dauerhaft, solange diese drei die einzigen Host-Abhängigkeiten sind; der Audit ist die Handlung, die der Abschnitt darüber beschreibt.",
			Abwesend: "tools/harness/"},
		{Modul: "modul-03-spec.md", Wert: TraegerKommtMit,
			Text: "`spec/lastenheft.md`, `spec/spezifikation.md` und `spec/architecture.md` liegen als ausgefüllte Dateien; die Klasse `spec-straten` des Doku-Gates hält ihre Richtung."},
		{Modul: "modul-04-adrs.md", Wert: TraegerKommtMit,
			Text: "`docs/plan/adr/` ist angelegt, die ADR-Vorlage liegt im mitgelieferten Vorlagen-Baum, und `.d-check.yml` verlangt für jede ADR-Kennung einen auflösenden Link."},
		{Modul: "modul-05-planning-harness.md", Wert: TraegerKommtMit,
			Text: "Die vier Lifecycle-Verzeichnisse unter `docs/plan/planning/` sind angelegt; `make slice-mv` bewegt einen Slice und zieht seine Verweise nach."},
		{Modul: "modul-06-roadmap.md", Wert: TraegerKommtMit,
			Text: "`docs/plan/planning/in-progress/roadmap.md` und die Register-Ablage `docs/plan/planning/observations/` liegen; `make archive-welle` archiviert die Zeitdokumente einer geschlossenen Welle."},
		{Modul: "modul-07-carveouts.md", Wert: TraegerLiegtBei,
			Text: "`docs/plan/carveouts/` ist angelegt und die Carveout-Vorlage liegt im mitgelieferten Vorlagen-Baum; kein Sensor prüft Frist oder Auflösungs-Trigger."},
		{Modul: "modul-08-agentenrollen.md", Wert: TraegerKommtMit,
			Text: "Unter `.claude/agents/` liegt je ein Rollen-Typ für die sechs kanonischen Rollen; der Typname trägt die Rolle in den Span."},
		{Modul: "modul-09-implementierung.md", Wert: TraegerKommtMit,
			Text: "`.claude/commands/implement-slice.md` führt den 8-Schritt-Workflow der Implementation-Rolle."},
		{Modul: "modul-10-review-harness.md", Wert: TraegerKommtMit,
			Text: "`.harness/skills/reviewer.md` trägt die Urteilsgrundlage der Review-Rolle."},
		{Modul: "modul-11-verification.md", Wert: TraegerLiegtBei,
			Text: "`.harness/skills/closure-note-reviewer.md` liegt im Ziel; ein eigenes Verifikations-Ziel führt der Aggregator nicht — die Prüfung hängt am Lauf, nicht an der Gate-Kette."},
		{Modul: "modul-12-replay-evaluierung.md", Wert: TraegerKommtNichtMit,
			Text: "Weder Golden Set noch Replay-Gate kommen mit — beide sind Gegenstand der Domäne dieses Repos, nicht des Bootstraps. Dauerhaft: ein repräsentatives Golden Set kann kein Werkzeug von außen setzen.",
			Abwesend: "harness/mk/"},
		{Modul: "modul-13-quality-gates.md", Wert: TraegerKommtMit,
			Text: "`make gates` aggregiert die Fragmente unter `harness/mk/`; jedes hängt seine Prüfungen an `GATE_CHECKS`, der Nachweis läuft zuletzt."},
		{Modul: "modul-14-docker-harness.md", Wert: TraegerKommtMit,
			Text: "Das Doku-Gate fährt in einem per Digest gepinnten Image; Tag und Digest stehen in `d-check.mk`."},
		{Modul: "modul-15-observability.md", Abschnitt: "§Erfassung und Token-Attribution", Wert: TraegerKommtMit,
			Text: "`harness/mk/erfassung.mk` trägt `span-report` und `span-clean` — beide in jedem Lauf. Der schreibende Teil hängt an einer Bedingung: Träger, Hook-Wrapper `.claude/hooks/span-emit.sh`, Hook-Eintrag und die Feldliste `harness/erfassung-feldliste.md` entstehen nur, wenn die Ablage des Trägers gelang; misslingt sie, endet der Bootstrap dennoch erfolgreich und diese vier fehlen."},
		{Modul: "modul-15-observability.md", Abschnitt: "§Doku-Konsistenz-Drift", Wert: TraegerLiegtBei,
			Text: "Das Doku-Gate bringt Module mit, die Ziel-Ansprüche und Code-Pfade prüfen; die Zeile `modules:` in `.d-check.yml` führt sie nicht — ihre Aktivierung ist eine eigene Entscheidung."},
		{Modul: "modul-16-produktiver-betrieb.md", Wert: TraegerLiegtBei,
			Text: "Betriebs-Regeln ohne eigene Mechanik im Bootstrap — der Text ist sein eigener Träger und hängt an keinem Trigger."},
	}
}

// TraegerInventur liefert die Inventur (fuer Tests und Inspektion).
func TraegerInventur() []TraegerEintrag { return traegerInventur() }

// TraegerInventurModule liefert die Regelblock-Dateinamen der Inventur, sortiert und
// ohne Wiederholung — die Menge, die test/baum-inventur.bats gegen das `regelwerk/`-
// Verzeichnis des gepinnten Baums haelt.
func TraegerInventurModule() []string {
	seen := map[string]bool{}
	out := []string{}
	for _, e := range traegerInventur() {
		if !seen[e.Modul] {
			seen[e.Modul] = true
			out = append(out, e.Modul)
		}
	}
	sort.Strings(out)
	return out
}

// emittierteKernpfade liefert die Ziel-Relpfade, die das Werkzeug als feste Adressen
// fuehrt — die Menge, gegen die eine Abwesenheits-Aussage der Inventur gehalten wird.
//
// GRENZE: die Menge ist der unbedingte Kern plus die Feldliste, die am Gelingen der
// Traeger-Ablage haengt (ADR-0022 Festlegung 7). Die Singletons aus dem Vorlagen-Satz,
// die Sprach-Phase und das konditionale Arch-Gate stehen nicht darin; eine Abwesenheits-
// Aussage ueber ein Praefix, das nur dort waechst, traegt dieser Bestand nicht.
func emittierteKernpfade() []string {
	paths := append([]string{}, EnforcePaths()...)
	paths = append(paths, CommandPaths()...)
	paths = append(paths, AgentPaths()...)
	paths = append(paths,
		MakefilePath,
		RootReadmePath,
		BaselineVerifyPath,
		BaselineMkPath,
		DocGateMkPath,
		FieldListPath,
		".d-check.yml",
		"d-check.mk",
	)
	sort.Strings(paths)
	return paths
}

// EmittierteAdressen liefert jede Ziel-Adresse, die ein Lauf schreiben KANN — den
// unbedingten Kern plus den Hook-Wrapper, der nur im Gelingens-Zweig der Traeger-Ablage
// entsteht (ADR-0022 Festlegung 5).
//
// Sie ist die Gegenmenge zu PfadBestand: jene haelt eine behauptete ABWESENHEIT gegen
// den unbedingten Bestand, diese eine behauptete ANWESENHEIT gegen alles, was ueberhaupt
// entstehen kann. Eine Zelle, die einen bedingten Traeger nennt UND seine Bedingung
// benennt, ist damit richtig; eine, die eine Adresse nennt, die kein Lauf schreibt, faellt.
func EmittierteAdressen() []string {
	adressen := append([]string{}, emittierteKernpfade()...)
	for _, f := range captureFiles() {
		adressen = append(adressen, f.dst)
	}
	sort.Strings(adressen)
	return adressen
}

// pfadEndungen sind die Datei-Endungen, an denen AdressenAusText eine Inline-Code-Spanne
// ohne Verzeichnis-Trenner noch als Pfad erkennt (`AGENTS.md`, `d-check.mk`).
func pfadEndungen() []string {
	return []string{".md", ".sh", ".yml", ".mk", ".json", ".awk"}
}

// AdressenAusText liefert die Ziel-Adressen, die eine Inventur-Zelle in Inline-Code
// nennt: jede Backtick-Spanne, die einen Verzeichnis-Trenner oder eine der
// pfadEndungen traegt. Eine Spanne mit Leerraum faellt heraus — so bleiben `make gates`
// und `direction: no-downward` draussen, ohne dass eine Namensliste noetig waere.
//
// GRENZE, benannt statt behauptet: die Regel verfuegt ueber eine FORM, nicht ueber den
// Sinn. Vier Stuecke fallen heraus. Ein Traeger, den eine Zelle in Prosa statt in
// Inline-Code nennt, bleibt ungeprueft. Ein nackter Name ohne Trenner und ohne eine der
// pfadEndungen ebenso — so fallen `baseline-verify`, `span-report`, `span-clean` und
// `GATE_CHECKS` heraus, und die Regel unterscheidet einen Ziel-Namen nicht von einem
// Konfigurations-Schluessel. Eine Adresse im vendored Baum liegt
// zwar im Ziel, aber ausserhalb der Menge des Emitters: sie schreibt der Fetch, und der
// Waechter meldete sie als unbekannt — deshalb nennen die Zellen diesen Baum in Prosa.
// Und dass die genannte Adresse die RICHTIGE fuer diesen Regelblock ist, sagt die Regel
// ohnehin nicht; das bleibt ein Urteil.
func AdressenAusText(text string) []string {
	out := []string{}
	for i, teil := range strings.Split(text, "`") {
		if i%2 == 0 || strings.ContainsAny(teil, " \t") || teil == "" {
			continue // ausserhalb der Spanne, oder keine Adresse
		}
		if strings.Contains(teil, "/") {
			out = append(out, teil)
			continue
		}
		for _, endung := range pfadEndungen() {
			if strings.HasSuffix(teil, endung) {
				out = append(out, teil)
				break
			}
		}
	}
	return out
}

// PfadBestand liefert sortiert die Kernpfade unter praefix — der Ist-Bestand, gegen den
// eine Abwesenheits-Aussage der Inventur gehalten wird.
func PfadBestand(praefix string) []string {
	out := []string{}
	for _, p := range emittierteKernpfade() {
		if strings.HasPrefix(p, praefix) {
			out = append(out, p)
		}
	}
	return out
}

// baumAussageAnker ist die Ueberschrift, VOR der der Block in die emittierte
// harness/conventions.md geht. Er sitzt damit am Ende von §Adoptierte Konventions-
// Quellen — dem Abschnitt, der den vendored Baum als Quelle einfuehrt — und laesst die
// oberste Gliederungs-Ebene der Vorlage unveraendert: der Block traegt nur `###`.
const baumAussageAnker = "\n## Adaptions-Block\n"

// baumAussageMarke ist die Ueberschrift, an der ein Waechter den Block im Ziel findet.
const baumAussageMarke = "### Was der mitgelieferte Baum ist — und was er nicht verspricht"

// baumAussageFreshnessMarke und baumAussageInventurMarke sind die zwei weiteren
// Ueberschriften des Blocks; jede traegt eine der drei Aussagen.
const (
	baumAussageFreshnessMarke = "### Der mitgelieferte Baum altert still"
	baumAussageInventurMarke  = "### Welche Regelblöcke des Baums hier einen Träger haben"
)

// baumAussage baut den Block aus den drei Aussagen und der Inventur.
//
// FAIL-CLOSED gegen einen Anspruch, den das Ziel nicht einloest: der fertige Block geht
// durch dieselbe Neutralisierung wie jedes emittierte Dokument (NeutralizeMakeClaims);
// veraendert sie ihn, nennt er ein `make`-Ziel, das die Init-Phase nicht schreibt, und
// der Bootstrap bricht ab, statt einen Platzhalter auszuliefern (LH-QA-01).
func baumAussage(targets []string) (string, error) {
	var b strings.Builder
	b.WriteString(baumAussageMarke + "\n\n")
	b.WriteString("Der Baum unter `.harness/baseline/` ist Kurs-Inhalt und in diesem Repo nicht\n")
	b.WriteString("autoritativ: er wird byte-genau so mitgeliefert, wie der Kurs ihn veröffentlicht, und\n")
	b.WriteString("vom Doku-Gate ausgenommen — `scan.ignore` in `.d-check.yml` nennt ihn. Was er an\n")
	b.WriteString("`make`-Namen nennt, sind **Beispiele des Kurses**, keine Ziele dieses Repos —\n")
	b.WriteString("maßgeblich ist allein `make help`. Dasselbe gilt\n")
	b.WriteString("für die Vorlagen darunter: wer eine kopiert, prüft ihre Ziel-Namen gegen `make help`,\n")
	b.WriteString("bevor er sie in ein lebendes Dokument übernimmt.\n\n")

	b.WriteString(baumAussageFreshnessMarke + "\n\n")
	b.WriteString("Der Baum ist auf einen Tag gepinnt — sein Verzeichnisname unter `.harness/baseline/`\n")
	b.WriteString("ist dieser Tag, und `make baseline-verify` nennt ihn in seiner Ausgabe. Erscheint\n")
	b.WriteString("upstream ein neueres Release, ändert sich hier nichts. `make baseline-verify` hält den\n")
	b.WriteString("Baum gegen `SHA256SUMS` — Integrität und Vollständigkeit, netzlos; über sein **Alter**\n")
	b.WriteString("sagt er nichts.\n\n")
	b.WriteString("Der Freshness-Audit ist deshalb eine **geschuldete Handlung dieses Repos**, kein Lauf:\n")
	b.WriteString("die **Release-Liste** des Kurs-Repos gegen den gepinnten Tag halten. Die Liste, nicht\n")
	b.WriteString("das Asset — ein Asset-Abgleich sagt, ob sich dieser Tag änderte, nicht, ob ein neuerer\n")
	b.WriteString("existiert. Die Adresse ist die **Release-Übersicht des Repos**, aus dem das Asset im\n")
	b.WriteString("Abschnitt *Adoptierte Konventions-Quellen* darüber stammt — nicht jene Asset-URL\n")
	b.WriteString("selbst, die genau einen Tag nennt. Der Audit ist im mitgelieferten Regelwerk\n")
	b.WriteString("ausgeschrieben.\n\n")
	b.WriteString("**Ein Sensor dafür kommt nicht mit, und das ist eine Aussage.** Er bräuchte einen\n")
	b.WriteString("Netz-Abruf der Release-Liste und damit eine Host-Abhängigkeit über `bash`, `git` und\n")
	b.WriteString("`docker` hinaus. Ein Repo, das nur diese drei voraussetzt, bekommt ihn nicht; was hier\n")
	b.WriteString("läuft, ist `make baseline-verify`, und das ist die Integritäts-Hälfte.\n\n")

	b.WriteString(baumAussageInventurMarke + "\n\n")
	b.WriteString("Je Regelblock des mitgelieferten Regelwerks genau einer von drei Werten — *Träger\n")
	b.WriteString("kommt mit* · *liegt bei, nicht verdrahtet* · *kommt nicht mit* (mit Grund und Dauer).\n")
	b.WriteString("Die Zelle sagt den Zustand **dieses** Repos, nicht den Stand einer Entscheidung.\n")
	b.WriteString("Wie viele Regelblöcke der Baum führt, sagt `ls .harness/baseline/*/regelwerk/*.md`.\n\n")
	b.WriteString("**Gesagt ist, was ein frisches Repo bekommt.** Ein Teil dieser Adressen gehört dem\n")
	b.WriteString("Adopter: dort legt der Bootstrap nur ab, wo nichts liegt, und eine vorhandene\n")
	b.WriteString("Fassung überlebt jeden weiteren Lauf unberührt. **Einen einzigen solchen Pfad nennt\n")
	b.WriteString("der Lauf** — den Commit-Träger `.githooks/commit-msg`. Für jeden anderen schweigt er:\n")
	b.WriteString("für die Dokumente der Doku-Kette, die Spec-Dateien, die Roadmap, `README.md`,\n")
	b.WriteString("`.d-check.yml`, die Rollen-Typen und die Workflow-Commands steht in der Ausgabe\n")
	b.WriteString("nichts — gleichgültig, ob er sie geschrieben oder stehen gelassen hat. Ohne Ausgabe\n")
	b.WriteString("erkennbar ist es am Inhalt: eine Datei, die der Bootstrap geschrieben hat, trägt\n")
	b.WriteString("seinen Text; eine, die er stehen ließ, den dieses Repos.\n\n")
	b.WriteString("**Gemessen gegen den Kurs-Stand `" + InventurMessTag + "`, und die Tabelle wandert nicht mit.** Sie\n")
	b.WriteString("nennt Regelblöcke beim Namen; ein Baseline-Sprung kann einen umbenennen, hinzufügen\n")
	b.WriteString("oder wegnehmen. Dieses Dokument wird von einem erneuten Bootstrap **nicht**\n")
	b.WriteString("überschrieben, und kein Lauf dieses Repos hält die Tabelle gegen den Baum, der hier\n")
	b.WriteString("liegt — wer den Baum tauscht, prüft sie von Hand gegen das Kommando oben.\n\n")
	b.WriteString("| Regelblock | Wert | Träger bzw. Grund und Dauer |\n")
	b.WriteString("|---|---|---|\n")
	for _, e := range traegerInventur() {
		block := "`" + e.Modul + "`"
		if e.Abschnitt != "" {
			block += " " + e.Abschnitt
		}
		fmt.Fprintf(&b, "| %s | %s | %s |\n", block, string(e.Wert), e.Text)
	}
	b.WriteString("\n")

	block := b.String()
	if neutral := NeutralizeMakeClaims(block, targets); neutral != block {
		return "", errors.New("baum-aussage nennt ein make-Ziel, das die Init-Phase nicht schreibt (LH-QA-01)")
	}
	return block, nil
}

// InjectBaumAussage setzt den Block vor die Ueberschrift des Adaptions-Blocks in die
// emittierte harness/conventions.md.
//
// FAELLT LAUT, wenn der Anker fehlt: ohne ihn hat der Block keinen Ort, und ein stiller
// No-op lieferte ein Ziel aus, das ueber seinen eigenen mitgelieferten Baum schweigt —
// genau der Zustand, den die drei Aussagen schliessen. Der Vorlagen-Satz gehoert dem
// Kurs und liegt unveraenderlich vendored; die Reparatur faellt darum emit-seitig.
func InjectBaumAussage(s string, targets []string) (string, error) {
	i := strings.Index(s, baumAussageAnker)
	if i < 0 {
		return "", fmt.Errorf("harness/conventions.md: Anker %q fehlt — der Baum-Aussage-Block hat keinen Ort", strings.TrimSpace(baumAussageAnker))
	}
	block, err := baumAussage(targets)
	if err != nil {
		return "", err
	}
	return s[:i+1] + block + s[i+1:], nil
}

// BaumAussageMarken liefert die drei Ueberschriften des Blocks — die Marken, an denen
// ein Waechter den Block im gebootstrappten Ziel findet.
func BaumAussageMarken() []string {
	return []string{baumAussageMarke, baumAussageFreshnessMarke, baumAussageInventurMarke}
}

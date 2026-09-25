# Slice slice-emittierte-dateien-behalten-lf-im-autocrlf-klon: Ein Klon mit `core.autocrlf=true` bekommt die Skripte des Werkzeugs mit LF

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Slice hat keine Closure-Bedingung, die von seiner eigenen DoD verschieden
ist: sein Beleg sind eine rot und grün gesehene `full-smoke`-Stufe, ein rot gesehener Go-Test und ein
grüner Gate-Lauf, und sie stehen in §2 (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine
Welle braucht).

**Ebene: Produkt-Code (Emission) und E2E-Skript — Dogfood *und* emittiert.** Zwei Schichten:
`internal/emit/` (die Emission) und `harness/tools/full-smoke.sh` (der Beleg). Die dritte Datei, die
Wurzel-`.gitattributes` dieses Repos, ist Konfiguration und keine Schicht; sie trägt dieselbe Zeile
wie die emittierten Dateien, liegt aber an einem anderen Ort, weil die Wurzel hier dem Repo gehört
(§1, Setzung 4).

**Bezug:**
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (Scope: erstklassig auf
Windows; die Grenze der Messmethode bleibt, §1),
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (die
Durchsetzungs-Mechanik, deren Skripte der Klon mit LF braucht),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (Boundary: konvergente
Dateien byte-identisch, skip-if-present-Dateien unberührt),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (jede Zahl dieses Plans
steht neben dem Kommando, das sie ausgibt),
[`ADR-0067`](../../adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md)
(**Accepted** — die Entscheidung, deren Vorgang dieser Slice ist: Menge, Zeile, Klasse je Pfad, Meldung
und Aussage-Reichweite),
[`ADR-0007`](../../adr/0007-bootstrap-phasen.md) (die zwei Idempotenz-Klassen und ihre Tabelle),
[`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) (die Bedeutung von
skip-if-present: freier Pfad wird geschrieben, belegter bleibt unberührt und der Lauf nennt ihn),
[`MR-055`](../../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)
(aus einer Messung an einer Stelle folgt nichts über eine Eigenschaft — der Grund, warum die Klasse für
`.claude/hooks/` nicht aus der Tabelle gelesen wird).

**Berührte Spec-Stellen:** — . Keine Spec-Stelle nennt `.harness/.gitignore` oder die Zeilenenden
emittierter Dateien (`grep -n '\.harness/\.gitignore' spec/*.md` → leer); die Emission ändert eine
Eigenschaft, die die Spec nicht beschreibt. [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
bekommt keinen Satz und keinen Change Request; die Grenze der Messmethode gilt unverändert
([`ADR-0067`](../../adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md)
Festlegung 5).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-24.

---

## 1. Ziel und Abgrenzung

<!-- BEDIENHINWEIS: Ziel = ein Satz, Liefer-Fokus, kein "wir machen
aufraeumen". Abgrenzung = je Punkt eine Begruendung, nicht nur eine Nennung:
ein Ausschluss ohne Grund ist eine Behauptung. Keine Mindestzahl — ein echter
Ausschluss ist besser als vier erfundene. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Ein Klon eines gebootstrappten Repos, den Git mit `core.autocrlf=true` auscheckt (das ist
die Standardeinstellung von Git for Windows), trägt in den Dateien, die das Werkzeug in den Verzeichnissen
aus Setzung 2 ablegt, LF statt CRLF — soweit die Datei mit LF im Index liegt und, in den drei
skip-if-present-Verzeichnissen, der Pfad frei war
([`ADR-0067`](../../adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md)
Festlegung 5). Belegt ist das von einer `full-smoke`-Stufe, die ohne die Emission rot ist. Dieses Repo
trägt dieselbe Zeile in seiner Wurzel.

**Die gemessene Lage** (Stand 2026-09-25; **keine Erwartungswerte**, die Zahlen wandern mit dem
Bestand — [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)):

- **Kein Träger existiert.** `git ls-files | grep -icE 'gitattributes|editorconfig'` → **0**.
- **Der Index ist LF.** `git ls-files --eol | awk '{print $1,$2}' | sort | uniq -c` → **2590**
  `i/lf w/lf`, **11** `i/none w/none`, **2** `i/-text w/-text` (die zwei PNG unter
  `docs/user/images/`) und **10** ohne Angabe (`git ls-files -s | grep -c '^120000'` → **10**, die
  Symlinks). Die Quelle ist CR-frei: `git grep -lI $'\r' | wc -l` → **0**. Eine emittierte Datei, die
  bewusst CRLF trägt, gibt es damit nicht — die Umkehrung, nach der der Auftrag fragt, ist leer.
- **Die CR entstehen im Klon, nicht im Bootstrap.** An diesem Repo, mit
  `T=$(mktemp -d); git clone -q --no-hardlinks -c core.autocrlf=true . "$T/k"`:
  `grep -rlI $'\r' --exclude-dir=.git "$T/k" | wc -l` → **2590**, `grep -c $'\r'
  "$T/k/.harness/baseline/v6.9.0/SHA256SUMS"` → **54** und `grep -c $'\r'
  "$T/k/.claude/hooks/pretooluse-command-guard.sh"` → **119**. Wer ein Repo bootstrappt, committet LF
  (die Vorlagen sind CR-frei); wer es danach klont — der zweite Entwickler, ein Windows-Runner —,
  bekommt CRLF.
- **Was daran bricht, ist gemessen für drei Konsumenten, nicht für alles.** Ein Bash-Skript über
  seine Shebang-Zeile (`#!/usr/bin/env bash\r` → `bash\r` nicht gefunden), die Byte-Prüfung des
  vendored Baums (`SHA256SUMS`) und eine Wortliste, die ein Skript einliest
  ([`ADR-0067`](../../adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md)
  §Kontext, mit den Kommandos). Ein Makefile mit CRLF läuft unter GNU Make 4.3 in den geprobten Formen;
  ein Windows-`make` und BuildKit über einem `Dockerfile` sind **nicht** gemessen.
- **Das Fehlerbild des Guards hat zwei Zustände.** Im gewöhnlichen autocrlf-Klon trägt auch der Guard
  CRLF und fällt **laut** aus (Exit 2 bei jedem Aufruf); **still** ist allein der Mischzustand, den eine
  Adopter-Wurzel mit Endungs-Glob erzeugt (Guard LF, `blocked/<sprache>` CRLF: die Wortliste verliert
  ihr letztes Wort). Die Emission hält beide Zustände aus dem Klon heraus; der Messweg zählt dafür
  CR-Bytes je Verzeichnis.
- **Die Alternative `* text eol=lf` ist rot gesehen.** In einem Wegwerf-Klon ohne `autocrlf` legt
  `git add --renormalize . && git diff --cached --name-only | grep -vc '^\.gitattributes$'` mit
  `* text eol=lf` → **2** Blobs um (beide PNG), mit `* text=auto eol=lf` → **0**.

**Setzungen des Planners** — jede mit dem, was passieren müsste, damit sie bricht. Menge, Zeile und
Klasse je Pfad entscheidet
[`ADR-0067`](../../adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md);
steht eine Aussage dieser Liste anders als dort, gilt die ADR.

1. **Die Form ist `* text=auto eol=lf`, verzeichnisweit mit `*` und nicht mit Endungs-Globs.**
   `text=auto` lässt Dateien, die Git als binär erkennt, in Ruhe — der Beleg oben; `eol=lf` legt dann
   das Auschecken jeder erkannten Textdatei fest, unabhängig von `core.autocrlf`. `*` statt `*.sh`:
   `blocked/<sprache>` und `commit-msg` tragen keine Endung, und ein Endungs-Glob erzeugt den stillen
   Mischzustand (Guard LF, Wortliste CRLF;
   [`ADR-0067`](../../adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md)
   Festlegung 2). Bricht, wenn Git eine Skript-Datei als binär einstuft (NUL-Byte): sie bekäme keinen
   LF-Zwang, und die Stufe misst den realen Bestand statt der Heuristik — **oder** wenn die emittierte
   Zeile ein Endungs-Glob trägt: dann liegt die Wortliste ohne Zwang, und der Eigenschafts-Test aus
   Liefer-Punkt 2 färbt rot.
2. **Die Verzeichnis-Menge ist das Kriterium aus
   [`ADR-0067`](../../adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md)
   Festlegung 1, keine Ableitung aus den Emissions-Einträgen:** ein Verzeichnis unterhalb der Wurzel des
   Ziels, in dem das Werkzeug eine Datei mit Interpreter- oder Byte-Konsument ablegt — ein Bash-Skript,
   ein awk-Programm, eine Wortliste, die ein Skript einliest, die Byte-Prüfung `SHA256SUMS` —, oder ein
   make-Fragment, dessen Rezepte Shell-Zeilen tragen (**Vorsorge**, kein gemessener Bruch). Heute
   sind das `tools/harness/`, harness/mk/, `.claude/hooks/`, `.githooks/` und `.harness/`. Nicht in der
   Menge: `.claude/` selbst und die Wurzel des Ziels (`Makefile`, `d-check.mk`, `a-check.mk`) — die
   Wurzel ist eine benannte Ausnahme vom Kriterium. Aus den Verzeichnissen aller `dst` in
   `enforceFiles()` ließe sich die Menge nicht ableiten (das ergäbe `.claude` statt `.claude/hooks`), und
   die Wortlisten unter `blocked/` sowie der vendored Baum unter `.harness/` entstehen außerhalb von
   `enforceFiles()` (`add-lang`, `internal/fetch/baseline.go`). Bricht, wenn die Anwendung des Kriteriums
   auf den vollständigen Emit ein Verzeichnis ergibt, das oben nicht steht (§4, Rückführung).
3. **Die Klassen folgen dem Boden** ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)-Vokabular;
   [`ADR-0067`](../../adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md)
   Festlegung 3, dort die Herkunft je Zeile): **konvergent** für `.harness/` und `tools/harness/` — das
   Werkzeug bestimmt dort, was liegt, und die Tabelle führt beide als tool-eigene Infrastruktur;
   **skip-if-present mit Meldung** für das make-Fragment-Verzeichnis harness/mk/, `.claude/hooks/` und
   `.githooks/` — dort trägt der Adopter oder ein fremdes Werkzeug den Namensraum mit (Zweifelsregel der
   Tabelle; [`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) Festlegung 3 für
   die Bedeutung). Die Meldung an einem belegten Pfad nennt den Pfad **und** die Aussage, was dann gilt:
   steht die Zeile dort nicht, tragen die Dateien des Verzeichnisses im Klon mit `core.autocrlf=true`
   CRLF. Bricht, wenn der zweite Lauf über einer belegten skip-if-present-Datei sie ändert oder schweigt,
   oder wenn ein konvergenter Pfad nach einer Verstellung nicht auf die Werkzeug-Fassung zurückkehrt
   (die Klassen-Kopplung je Pfad aus Liefer-Punkt 2).
4. **Dieses Repo bekommt eine Wurzel-Datei, keine genesteten.** Die Wurzel gehört hier dem Repo
   (Ebene: Dogfood, Konfiguration); sie deckt `.claude/hooks/`, `harness/tools/`, `.githooks/`, den
   vendored Baum `.harness/baseline/` (byte-genau gehalten von `SHA256SUMS`) und das `Makefile` mit einer
   Zeile. Die genesteten Dateien der Emission gehören dem emittierten Ziel; im Dogfood-Layout gäbe es
   harness/mk/ und `tools/harness/` nicht einmal. Bricht, wenn die Zeile einen Blob umlegt: das
   Kommando aus Liefer-Punkt 3 nennt dann die Datei.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Wurzel-`.gitattributes` des Adopters, und damit `Makefile`, `d-check.mk`, `a-check.mk`,
  `.d-check.yml`, `Dockerfile` im Ziel** — *Bestand bleibt bewusst stehen.* Eine genestete Datei
  erreicht die Wurzel nicht, und die Wurzel gehört dem Adopter; die genesteten Dateien gewinnen
  umgekehrt gegen eine Adopter-Wurzel, sodass deren Zeilen die Verzeichnisse der Emission nicht
  aufheben ([`ADR-0067`](../../adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md)
  Festlegung 5). Gemessen ist für das `Makefile` unter GNU Make 4.3 **kein** Bruch (oben), für ein
  Windows-`make` und für BuildKit nichts; eine Wurzel-Zeile ohne diese Messung wäre eine Zusage ohne
  Gegenbeispiel. **Die Option „eine Datei in der Wurzel des Ziels" ist gewogen und nicht gewählt:** eine
  skip-if-present-Datei dort schützte ein Ziel mit eigener Wurzel-Datei gar nicht, und ein Marker-Block
  schriebe in eine Adopter-Datei
  ([`ADR-0067`](../../adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md)
  Alternative D). Die Restmenge wird von der Stufe **ausgegeben** (§2, Liefer-Punkt 1), nicht
  zugesagt; Ausgang in §6.
- **Ein Windows-Volllauf** — *anderer Vorgang / Grenze der Messmethode.* Die Runner tragen keine
  Linux-Container ([`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix), Grenze
  der Messmethode); die Stufe belegt, was `core.autocrlf=true` mit den Bytes macht, nicht dass ein
  Bootstrap auf Windows durchläuft.
- **Symlinks unter `.claude/rules/` und `core.symlinks`** — *anderer Vorgang.* Andere Ursache
  (Symlink-Recht des Windows-Nutzers, nicht Zeilenende), anderer Sensor; ein gemeinsamer Slice
  verschmierte zwei Messungen.
- **`.editorconfig`** — *Vorgriff.* Sie steuert Editoren, nicht `git`; nichts im Bestand belegt
  einen Bedarf.
- **Bereits mit CRLF ausgecheckte Arbeitsbäume in Adopter-Repos** — *Bestand, Sache des Adopters.*
  Die Attribute wirken beim nächsten Checkout; ein vorhandener Arbeitsbaum behält seine CRLF bis dahin
  (`git add --renormalize .` ist sein Vorgang, das Werkzeug fasst keinen fremden Arbeitsbaum an).
- **Eine Datei, die ein Adopter mit CRLF im Index führt** — *Bestand, Sache des Adopters.* Sie bleibt
  trotz `text=auto eol=lf` CRLF; die Zusage aus dem Ziel gilt für eine Datei, die mit LF im Index liegt,
  und der Messweg committet LF, weil die Emission CR-frei schreibt
  ([`ADR-0067`](../../adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md)
  §Konsequenzen, akzeptiertes Negativ).

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

**Liefer-Punkte (drei, in dieser Reihenfolge — der Messweg zuerst, damit das Gegenbeispiel rot
gesehen wird, bevor es etwas zu heilen gibt):**

- [ ] **1 · Messweg.** Eine neue Stufe in `harness/tools/full-smoke.sh` — Kopfzeile der Form
      `echo "full-smoke: …"` **und** ein `e2e_abdeckung`-Aufruf mit den Kennungen
      [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) und
      [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), sonst fällt sie
      aus der Sicht ([`docs/user/e2e-abdeckung.md`](../../../user/e2e-abdeckung.md), die
      `make e2e-abdeckung` erzeugt; die Lücken-Richtung *Stufe ohne Deklaration* färbt den Erzeuger
      rot). **Nicht [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix):** keine Stufe
      nennt sie heute (`grep -c 'LH-QA-0[4]' docs/user/e2e-abdeckung.md` → **0**), und eine Linux-Stufe in
      der Zeile der Windows-Anforderung läse sich als Windows-Beleg, den die Stufe nicht liefert.
      [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) trägt die
      Skripte der Durchsetzungsschicht (`tools/harness/`, Hooks, git-eigener Träger), deren Bytes die
      Stufe hält, [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) den Bootstrap, den
      sie fährt. Sie bootstrappt in ein tmp-Repo, committet, klont einmal mit `-c core.autocrlf=true` und
      einmal mit `-c core.autocrlf=false` **(Kontrollklon — ausdrücklich gesetzt, nicht vom Runner
      geerbt)** und zählt Dateien mit CR unter der Verzeichnis-Menge aus Setzung 2. Belegt:
      (a) der Kontrollklon trägt keine — die Stufe kann nicht aus falschem Grund rot sein; (b) der
      autocrlf-Klon trägt keine, `.githooks/commit-msg` läuft dort über seine Shebang-Zeile, und
      `bash tools/harness/baseline-verify.sh` endet mit `OK` (die Byte-Prüfung des vendored Baums; als
      Beleg des dritten Konsumenten gewählt, ohne einen Liefer-Punkt mehr); (c) **rot gesehen vor
      Punkt 2** — ohne die Emission trägt der autocrlf-Klon CR-Dateien, und der Shebang-Lauf scheitert
      mit `bash\r`, die Meldung nennt die Datei; (d) die **Restmenge** (Dateien mit CR nach dem Fix, im
      Ziel die Wurzel-Dateien des Adopters) gibt die Stufe aus, statt sie zu verschweigen. Was die Zusage
      bricht: eine der Emissions-Zeilen fehlt oder trägt `eol=crlf` — das Rot muss die CR-tragende Datei
      nennen (Meldung lesen, nicht nur den Exit-Code). **Die Stufe beschreibt ihren Gegenstand als
      Laut-Ausfall:** im gewöhnlichen autocrlf-Klon fällt der Guard laut aus (Exit 2), und still ist nur
      der Mischzustand aus Setzung 1 — kein Wort „still" für den gewöhnlichen Klon in Kopfzeile,
      Meldungen und `e2e_abdeckung`-Text.
- [ ] **2 · Emission.** Die genesteten `.gitattributes` mit der Zeile aus Setzung 1 in den fünf
      Verzeichnissen aus Setzung 2, je Eintrag mit der Klasse aus Setzung 3 in `enforceFiles()`; die drei
      skip-if-present-Einträge tragen eine Meldung, die den Pfad **und** die Aussage nennt, was dann
      gilt. Zwei neue Go-Tests, gemessen an einem Emit, der die Wortliste unter `blocked/` und die
      Dateien unter `.harness/` enthält:
      **(a) Eigenschaft statt Verzeichnis-Liste** — für jede emittierte Datei mit Interpreter- oder
      Byte-Konsument (Shebang-Zeile, Endung `.sh`/`.awk`/`.mk`, Wortliste unter `blocked/`, Datei unter
      `.harness/`, Datei unter `.githooks/`) liegt in einem Vorfahr-Verzeichnis unterhalb der Wurzel eine
      emittierte `.gitattributes`, die die Zeile `* text=auto eol=lf` trägt; die Wurzel-Dateien
      (`Makefile`, `d-check.mk`, `a-check.mk`) sind die benannte Ausnahme
      ([`ADR-0067`](../../adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md)
      Festlegung 1 und Fitness-Zeile 1). Der Test liest den emittierten Baum und leitet die erwartete
      Menge **nicht** aus der Verzeichnis-Liste ab, die die Emission liest — ein Test, der die Quelle
      gegen sich selbst hält, kann unter keiner Mutation rot werden
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Rot gesehen durch Streichen eines Eintrags, durch
      `eol=crlf` **und** durch einen Endungs-Glob statt `*`. **(b) Meldungsinhalt je
      skip-if-present-Pfad** — an einem belegten Pfad (fremder Inhalt ohne `eol=lf`) nennt die Meldung des
      Laufs den Pfad und die Aussage aus Setzung 3; rot gesehen durch eine Meldung, die nur den Pfad
      nennt. Die bestehende Klassen-Kopplung `TestEnforce_IdempotenzKlasseJePfad` läuft über
      `PathClass`/`EnforcePaths()` und trägt die neuen Pfade, sobald sie in der Aufzählung stehen —
      kein dritter neuer Test. Ein zweiter `init`-Lauf heilt die konvergenten Dateien (`.harness/`,
      `tools/harness/`) und lässt die drei skip-if-present-Dateien unberührt und nennt sie
      ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), Boundary). Dazu Fälle in
      `test/mutations/`: ein Eintrag entfällt bzw. die Zeile trägt `eol=crlf` bzw. einen Endungs-Glob →
      Test (a) färbt rot; die Meldung verliert die Aussage → Test (b) färbt rot.
- [ ] **3 · Dogfood.** Die Wurzel-`.gitattributes` dieses Repos mit der Zeile aus Setzung 1 — Konfiguration
      und Lieferung dieses Slice, keine dritte Schicht; die Renormalisierung im Ziel ist nicht
      Gegenstand. Beleg —
      vorher und nachher dasselbe Kommando: `git ls-files --eol | awk '{print $1,$2}' | sort | uniq -c`
      unverändert (die zwei `i/-text` bleiben), im Wegwerf-Klon
      `git add --renormalize . && git diff --cached --name-only | grep -vc '^\.gitattributes$'` →
      **0**, und ein Klon von HEAD mit `-c core.autocrlf=true` trägt `grep -c $'\r'` **0** in
      `SHA256SUMS` (heute 54) und in `pretooluse-command-guard.sh` (heute 119) und denselben sha256
      für die zwei PNG. Die Messung steht in der Closure-Notiz; sie ist kein Gate.

**Konstante Pflichten (zählen nicht mit):**

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: [`docs/user/e2e-abdeckung.md`](../../../user/e2e-abdeckung.md) aus `make e2e-abdeckung`
      regeneriert; [`harness/sensors/full-smoke.md`](../../../../harness/sensors/full-smoke.md), falls es
      die Stufen aufzählt; die Klassen-Tabelle bzw. Inventur der Emission
      (`internal/emit/baumaussage.go`), soweit sie die neuen Pfade nennen muss.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/full-smoke.sh` | update | Punkt 1: neue Stufe (Kopfzeile + `e2e_abdeckung` mit [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) und [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)), Kontrollklon, Shebang-Lauf, Byte-Prüfung, Restmenge |
| `docs/user/e2e-abdeckung.md` | update (erzeugt) | `make e2e-abdeckung`; den Inhalt hält `test/e2e-abdeckung.bats` |
| `internal/emit/templates/enforce/gitattributes` | neu | eine Vorlage, die Zeile aus Setzung 1; dot-lose Quelle wie `gitignore` (`all:templates/enforce`) |
| `internal/emit/enforce.go` | update | fünf Einträge in `enforceFiles()` mit ausgewiesener Klasse und, für die drei skip-if-present-Einträge, der Meldung nach Setzung 3; die Klasse eines Eintrags steht nur dort |
| `internal/emit/enforce_test.go` (o. ä.) | update | Punkt 2: Eigenschafts-Test (a) und Meldungs-Test (b); die bestehende Klassen-Kopplung (`PathClass`) trägt die neuen Pfade mit |
| `test/mutations/` | neu | Fälle: Eintrag streichen, Zeile auf `eol=crlf` bzw. Endungs-Glob → Test (a); Meldung ohne Aussage → Test (b) — erwartet rot färbender Test je Fall benannt; Anker gegen den Quell-Bestand gemessen ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)) |
| `.gitattributes` (Wurzel) | neu | Punkt 3: dieselbe Zeile, Wurzel gehört hier dem Repo |

- **Reihenfolge im Lauf:** Punkt 1 committen und rot sehen (der Lauf bootstrappt mit dem Träger, den
  `make full-smoke` baut), dann Punkt 2, dann Punkt 3. Zwei Commits mindestens, damit das Rot
  einen Stand hat.
- **Die Stufe liest `git`, nicht das Werkzeug.** `core.autocrlf=true` wirkt in jedem Git und
  damit auch unter Linux; die Stufe belegt den Smudge-Filter auf den Bytes, die das Werkzeug ablegt.
  Sie belegt **nicht**, dass ein Windows-Git dieselbe Konfiguration liest.
- **Betroffen von der Emission sind auch die Selbstprüfung und die Inventur des Ziels:** die neuen
  Pfade tauchen in `internal/emit/baumaussage.go` und in dem, was das Ziel über seinen eigenen Baum
  sagt, auf — der Implementer prüft beide Richtungen (der Eintrag
  `emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` steht in §8).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [`ADR-0067`](../../adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md)
steht auf `Accepted`, und das Verzeichnis `in-progress/` trägt keinen anderen Slice (WIP-Limit 1).
Beobachtbar: der Status-Kopf der ADR im gemergten Stand und ein `ls docs/plan/planning/in-progress/`
ohne Slice-Datei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die Anwendung des Kriteriums (§1 Setzung 2)
  auf den vollständigen Emit ergibt mehr als die fünf genannten Verzeichnisse — etwa weil das
  Sprachskelett (`internal/gen/`) Dateien mit Interpreter-Konsument trägt — **oder** die Stufe braucht
  mehr als die eine Kontroll-/autocrlf-Klon-Struktur, um rot zu werden.
- `in-progress` → `open` (blockiert — Carveout?): eine Messung am Ziel widerlegt eine Aussage der ADR —
  etwa dass die genestete Zeile gegen eine Adopter-Wurzel gewinnt (Festlegung 2) — dann ist es eine
  Folge-ADR mit `Supersedes`, kein Nachtrag dieses Slice.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei Kriterien: (1) die neue `full-smoke`-Stufe läuft grün **und** ihr Rot vor Punkt 2 ist im
Review-Report mit der gelesenen Meldung belegt; (2) `make gates` grün auf dem Stand nach Punkt 3,
und die Messung aus Punkt 3 steht in der Closure-Notiz. Dazu der Lerneintrag; der Abschluss läuft
im Planner-Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10), nicht im Lauf, der den Slice gebaut hat.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Stufe belegt den Smudge-Filter von Git unter Linux, nicht Windows.** Ein Unterschied, den
  nur ein Windows-Git zeigt (andere Konfigurationsebene für `core.autocrlf`, `core.symlinks`,
  Ausführungsbit), bleibt unbelegt; die Grenze der Messmethode aus
  [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) gilt unverändert —
  **Ausgang:** weiter offen → `BEO-ALL/messung-ersetzt-die-zielplattform-durch-ihren-git-filter`
  (Neuanlage bei der Closure, Beleg `evidence/slice-emittierte-dateien-behalten-lf-im-autocrlf-klon.md`).
- **Die Wurzel-Dateien des Adopters (`Makefile`, `d-check.mk`, `a-check.mk`, `.d-check.yml`,
  `Dockerfile`) bleiben ohne Attribut, und ob ein Windows-`make` oder BuildKit an CRLF bricht, ist
  ungemessen** (unter GNU Make 4.3 bricht das `Makefile` nicht, §1). Die Stufe gibt die Restmenge aus —
  **Ausgang:** weiter offen → `BEO-ALL/emittierte-wurzel-dateien-ohne-zeilenenden-attribut`
  (Neuanlage bei der Closure; der Zähler folgt aus den Dateien unter `evidence/`).
- **`text=auto` stuft eine emittierte Skript-Datei als binär ein und lässt sie mit CRLF stehen.**
  **Ausgang:** entfallen — die Stufe zählt CR-Bytes und führt `.githooks/commit-msg` über seine
  Shebang-Zeile, beides an den realen Bytes; eine als binär eingestufte Datei färbte sie rot, und ihr
  Rot nennt die Datei (Liefer-Punkt 1, Zusage und Gegenbeispiel).
- **Die Meldung an einem belegten skip-if-present-Pfad erscheint auch über der eigenen Datei des
  ersten Laufs** (der Lauf unterscheidet nicht, wessen Datei liegt). **Ausgang:** entfallen — kein
  Risiko dieses Slice, sondern das benannte, akzeptierte Negativ der Entscheidung
  ([`ADR-0067`](../../adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md)
  Festlegung 4: benannt, nicht verhindert; eine Byte-Gleichheits-Ausnahme wäre ein neuer Pfad im
  Writer für drei Zeilen Ausgabe).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

*Wird bei der Closure vom Planner geschrieben, nicht vom Lauf, der den Slice baut
([`AGENTS.md`](../../../../AGENTS.md) §3.10). Bis dahin stehen die Ausgänge der Risiken in §6.*

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area, `*` (`ALL`): der Träger liegt
in `internal/emit/`, der Beleg in `harness/tools/full-smoke.sh`, die Konfiguration in der Wurzel.
`harness/tools/` (`TOOLS`) ist als Pfad berührt (`full-smoke.sh`), aber die Modus-Deklaration führt für
dieses Skript keine eigene Reife-Achse, und dieser Slice legt keine an; `.codex/` (`CODEX`) ist nicht
berührt. Beide deklarierten Sub-Areas sind GF.

**Vorgelagert — offene Beobachtungen sichten:** Das Register unter
[`../observations/`](../observations/) ist durchgegangen; die Zähler sind als Dateizahl unter
`evidence/` abgelesen
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, **keine
Erwartungswerte** —
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2, gelesen am gemergten Stand vom 2026-09-25). Kein Eintrag nennt Zeilenenden,
`.gitattributes` oder `autocrlf` (`grep -rliE 'crlf|zeilenende|autocrlf|gitattributes'
docs/plan/planning/observations/BEO-ALL --include=observation.md` → leer) — die Fragestellung ist
neu. Diese Einträge betreffen den Vorgang:

| Eintrag | Zähler | Stand | Bezug zu diesem Slice |
|---|---|---|---|
| `emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` | 2× | offen | **unmittelbar** — die neuen Pfade sind Emit-Ausgänge, deren Klasse (skip-if-present behält, konvergent heilt) das Ziel über seinen Baum sagt; **erreicht der Eintrag mit diesem Slice 3×, ist er keine Notiz mehr, sondern eine Lücke** — der Lese-Schritt der Closure entscheidet, ob ein Beleg hier hineingehört, und schneidet dann einen eigenen Folge-Slice |
| `idempotente-anlage-erreicht-den-bestand-nicht` | 2× | offen | die skip-if-present-Hälfte (`.githooks/.gitattributes`) und der Heil-Lauf der konvergenten Dateien werden über einem **bereits belegten** Pfad gemessen, nicht nur im leeren Zielbaum — dieselbe Klasse wie beim Commit-Träger |
| `mess-rezept-setzt-unbenannte-host-konfiguration-voraus` | 2× | offen | **unmittelbar** — `core.autocrlf` ist Host-Konfiguration: der Kontrollklon setzt sie ausdrücklich (`-c core.autocrlf=false`) statt sie vom Runner zu erben |
| `beleg-faehrt-den-behaupteten-pfad-nicht` | 1× | offen | die Stufe muss den behaupteten Pfad fahren (echter Klon mit Smudge-Filter, echter Shebang-Lauf), nicht ein Muster über Dateinamen |
| `byte-gleichheit-als-aussage-ueber-die-regel-gelesen` | 2× | offen | Liefer-Punkt 3 vergleicht Bytes vor und nach; er sagt etwas über die Bytes, nicht über die Regel |
| `emittierter-stand-laeuft-dem-dogfood-voraus` | 2× | offen | Dogfood und Emission tragen dieselbe Zeile an verschiedenen Orten; kein Modul hält die beiden Fassungen zusammen — benannt, hier nicht geschlossen |
| `lokaler-full-smoke-scheitert-auf-macos-host` | 2× | offen | die Stufe läuft unter Linux/CI wie jede andere `full-smoke`-Stufe; ein lokaler macOS-Lauf bleibt ihr verwehrt |
| `neuer-waechter-ohne-mutations-fall` | 13× | verkörpert | Liefer-Punkt 2 trägt seinen Fall in `test/mutations/` |
| `zusage-ohne-herstellbares-gegenbeispiel` | 3× | verkörpert | der Messweg steht vor der Emission, damit das Rot gesehen wird |
| `emittierte-vorlagen-klassifikation-ohne-traeger` | 3× | geplant | nur mittelbar — sie fragt, ob ein Ort im Ziel entsteht; hier ist der Ort fest, nur seine Klasse ist offen |

**Keine Ausgänge werden hier zugewiesen oder erhöht**; alle Bezeichnungen sind **zitiert**, nicht neu
formuliert. Die zwei Neuanlagen aus §6 entstehen bei der Closure, nicht jetzt.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Modus:** alle berührten Sub-Areas **GF** — der Begründungsblock entfällt damit nach der
Umfangs-Regel dieser Sektion.

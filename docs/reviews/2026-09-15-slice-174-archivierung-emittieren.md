# Review-Report: slice-174-archivierung-emittieren — 2026-09-15

**Review-Art:** Code-Review gegen **Plan + ADRs + Hard Rules** (Modul 10 §Drei Review-Arten).
Gegenstand sind eine neue Emissions-Vorlage (ein `make`-Fragment), ihre Go-Abbildung, drei Go-Tests,
ein E2E-Abschnitt, ein bats-Fall und fünf Mutations-Fälle. **Kein DoD-Review** — DoD-/Spec-Konformität
prüft der Verifier (Modul 11, anderer Eingabe-Kontext).

**Gegenstand:** Commit `3e535c3c` (Rolle Implementer), 12 Dateien, +577/−1. Der Planner-Nachzug
`b8456062` (der Anlass-Block eines DoD-Punkts, `docs/plan/planning/**`) ist **nicht** Gegenstand, aber
gelesen; er berührt keine geprüfte Datei.

**Kein Self-Review:** dieser Lauf hat an dem Commit nicht geschrieben. Kein Befund dieses Reports ist
aus der Commit-Message oder aus dem Implementer-Bericht übernommen — die dort als strittig gemeldeten
Punkte (Sperren-Vererbung, `make`-Exit-Code, Rollen-Frage) sind einzeln nachgemessen (§1 bis §6).

**Skill:** `.harness/skills/reviewer.md` @ `0565f274` (2.0.0) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** deepseek-v4.1-flash:cloud[1m] · **Datum:** 2026-09-15

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt
> genau einen Tag; der Sprung löscht den alten, und ein Link darauf färbt beim
> nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein `pfad`-Feld
> auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den
> Stand des Laufs und darf ihn festhalten.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan `slice-174-archivierung-emittieren` (§1 Ziel und Abgrenzung, §2 DoD, §3 Plan, §4 Trigger,
  §5 Closure-Trigger, §6 Risiken, §8)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules; tragend hier §3.6, §3.7, §3.8, §3.9)
- [`ADR-0033`](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) (Festlegung 1, 4, 5
  und die Folgepflichten 6 und 8) · [`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  (Festlegung 1, §Was hier NICHT entschieden ist, §Folgepflicht 3) ·
  [`ADR-0007`](../../docs/plan/adr/0007-bootstrap-phasen.md) (Idempotenz-Klassen-Tabelle) ·
  [`ADR-0022`](../../docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (Festlegung 5b, 6)
- [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) ·
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) §Adaptierbar ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
- [`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption) ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) ·
  [`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
- Baseline `v6.8.0` · `regelwerk/modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz ·
  `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill
- Vorherige Findings am **selben Modul** (emittierte Mechanik, E2E-Beleg, Anker aus der Prosa):
  `2026-09-14-slice-vorlauf-waechter-geht-ins-ziel.md` (F-1) · `2026-09-13-slice-073-emittierte-doc-gate-module-runde-5.md`
  — daraus die wiederkehrende Klasse `test-anker-aus-der-prosa-erfuellbar`

---

## Eigene Messungen

Jedes Kommando dieses Abschnitts ist in diesem Lauf gefahren. Wo eine Zahl steht, steht das Kommando
daneben, das sie liefert; **keine Erwartungswerte**
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

### 1. Mutation `337` einzeln — der benannte Wächter färbt rot, mit der behaupteten Ursache

```text
$ bash test/mutations/337-archivierung-haengt-an-gate-checks.sh && git diff --stat
 internal/emit/templates/enforce/archivierung.mk | 1 +
$ make test-go
--- FAIL: TestArchivierungFragment_ZielAmTraegerUndNichtInDerGatesKette (0.01s)
    archivierung_test.go:116: harness/mk/archivierung.mk haengt [archive-welle] an GATE_CHECKS — es traegt ein Kommando, kein Gate
    archivierung_test.go:123: "archive-welle" haengt in der gates-Kette des Ziels — ein Gate ueber einer Archivierung waere eines ueber leerem Pruefbereich: [archive-welle baseline-verify build docs-check gates lint record-gates test]
```

**Beide** Zusicherungen des Falls feuern, und die zweite nennt die **gelesene** transitive Hülle samt
ihrer Vorbedingungs-Mitglieder. Der Fall trifft die Zusage, nicht eine Nebenwirkung. Danach
`git checkout -- internal/emit/templates/enforce/archivierung.mk` → `git status --porcelain` leer.

### 2. Mutation `334` einzeln — derselbe Nachweis für die zweite Go-Stufe

```text
$ bash test/mutations/334-archivierungs-fragment-am-traeger-zweig.sh && git diff --stat
 internal/emit/enforce.go | 3 +++
$ make test-go
--- FAIL: TestArchivierungFragment_LiegtAuchOhneTraeger (0.00s)
    archivierung_test.go:91: lesen …/harness/mk/archivierung.mk: open …: no such file or directory
```

Der Fall färbt den **benannten** Wächter rot. Die Ursache ist dieselbe, die der Fallkopf nennt (das
Fragment fällt mit dem Träger), sie kommt hier aber als Lesefehler statt als die ausgeschriebene
Meldung — siehe Negativbefunde.

### 3. Die `make`-Exit-Grenze, an einem Wegwerf-Rezept gemessen

```text
$ printf 't:\n\t@exit 3\n' > /tmp/exitprobe/Makefile && make -C /tmp/exitprobe t; echo $?
make: *** [Makefile:2: t] Fehler 3
2
```

`make` exitet **2** und nennt die **3** in seiner Meldung. Die Behauptung der Commit-Message ist damit
in beiden Hälften richtig: der Rezept-Exit kommt nicht über `$?` an, und die Sperren sind an ihrer
Ausgabe gelesen.

### 4. `make full-smoke` — die Sperren-Vererbung am gebootstrappten Ziel, selbst gefahren

```text
$ make full-smoke 2>&1 | tail -40        # Ausgabe der Laufspitze ist durch den tail beschnitten
full-smoke: OK — ARCHIVIERUNG IM ZIEL (ADR-0033 Festlegung 4 und 5): make archive-welle ist kein
  Gate, erreicht aber im gebootstrappten Repo den abgelegten Traeger — die zwei Sperren [untergrenze]
  und [haenger] halten den Aufruf auf, ueber demselben Bestand ohne sie laeuft die Operation real
  (Archiv + Stubs aus der vendored Vorlage), und ohne Traeger meldet das Kommando die Abwesenheit mit Exit 0.
FULLSMOKE_EXIT=0
$ grep -n 'full-smoke: FEHLER' <aufgefangenes Lauf-Ende>          # 0 Treffer
```

**Die tragende Zeile ist `FULLSMOKE_EXIT=0`**, nicht die OK-Zeile allein: `archivierung_im_ziel()`
exitet bei jeder verletzten Zusicherung mit 1, und die OK-Zeile steht in der Schlussliste, die nur
erreicht, wer bis zum Ende kommt. **Grenze der Messung, benannt:** gefangen wurde das Lauf-Ende
(40 Zeilen); die Abschnitts-Zwischenzeilen (`full-smoke: Sperren erreichen den Aufruf …`) liegen
außerhalb des Fensters und sind darum hier nicht zitiert — der Exit-Code trägt sie.

### 5. Die vier Aussagen des E2E gegen ihren Text gelesen

- **(c) „KEIN Gate"** — `make -n gates` über dem Ziel; die Prüfung hat Zähne, weil `make -n` das Rezept
  eines Ziels in der Kette mitschreibt und die Fragment-Rezeptzeilen den Namen tragen
  (`harness/tools/full-smoke.sh:1078`). Die einseitige Richtung ist als F-4 benannt.
- **(a) Sperren** — derselbe Aufruf wie (b), über einem Bestand mit **beiden** Auslösern; verlangt
  `Exit ≠ 0`, beide Marken in der Ausgabe und `done/<welle>/` weiterhin leer. Gelesen, nicht geglaubt:
  §4.
- **(b)/(d)** — über demselben Bestand ohne die Auslöser läuft die Operation real; ohne Träger endet
  sie mit 0 und meldet. Gelesen.

### 6. Der Zuschnitt des Fragments, an der Go-Abbildung gelesen

```text
$ grep -n 'captureErr\|captured :=\|for _, f := range enforceFiles' internal/emit/enforce.go
210: captureErr := placeCarrier(targetDir)
211: captured := captureErr == nil
214: for _, f := range enforceFiles() {
242: if !captured { return nil }
```

`archivierungFile()` steht in `enforceFiles()`, also **vor** dem Ausgangs-Zweig; `Enforce` schreibt
diese Menge konvergent (Kopfkommentar `enforce.go:180-183`) und prunt nie. Der Wächter `334` misst
genau diesen Zuschnitt.

### 7. Der neue Text und die Verbotslisten

```text
$ grep -c 'harness/tools/' internal/emit/templates/commands/*.md
internal/emit/templates/commands/close-welle.md:0
internal/emit/templates/commands/implement-slice.md:0
internal/emit/templates/commands/plan-welle.md:0
```

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills**. Die Spalten sind gespiegelt, nicht neu
definiert; bei Abweichung gilt der Skill.

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Der Quelltext eines **Rollen-Anweisungssatzes** wurde im Implementations-Kontext geändert: die Datei führt im Eröffnungssatz *„Dieser Command führt die **Planner**-Rolle für die **Wellen-Closure**"* und distilliert damit den Ablauf genau einer Rolle, den sie selbst nach dem Kriterium *„welche Rolle führt diesen Ablauf aus"* der Planner-Rolle zuordnet; [`ADR-0033`](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 4 nennt den Text des emittierten Anweisungssatzes ausdrücklich *„ein Rollen-Anweisungssatz"*, der *„nach [`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) der ausführenden Rolle"* gehört, und der **Plan** dieses Slice erklärt dieselbe Text-Hälfte in §6 selbst zur *„Übergabe, keine Implementer-Entscheidung"* — geschrieben hat sie dieser Lauf. **Die Gegenlesart steht im Bestand und wird hier nicht entschieden:** [ADR-0028](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) führt unter §Was hier NICHT entschieden ist namentlich *„und die emittierte Ebene"* und glossiert sie in §Folgepflicht 3 als *„ob ein erzeugtes Repo eine Eigentums-Aussage über seine Anweisungssatz-Artefakte bekommt"*; welcher der zwei Sätze greift, ist ein Rollen-Verdikt und keine Reviewer-Frage. Bis dahin steht die Grenze als **HIGH mit Rollen-Konflikt** und geht den Konflikt-Pfad (`v6.8.0` · `regelwerk/modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz): das Verdikt ist ein Artefakt, ein Herabstufen wäre selbst eines. Die Zuschnitt-Praxis stützt die Planner-Lesart — dieselbe Datei wurde für eine Inhaltsänderung als *„Rolle Planner … (lokal + emittiert)"* committet (`0203d83a`), Implementer-Commits auf ihr sind Nacharbeit an Schritt-Verweisen (`04c8f950`). | [`AGENTS.md`](../../AGENTS.md) §3.8 · [ADR-0028](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) · [ADR-0033](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 4 | `internal/emit/templates/commands/close-welle.md:89` | nein — kein Modul liest Rollen oder Commit-Zuschnitt ([`AGENTS.md`](../../AGENTS.md) §3.8, *Ein Wächter existiert nicht*) | fremdes-rollen-artefakt-im-implementations-kontext |
| F-2 | MEDIUM | Der neue ANPASSEN-Marker lädt zu einer **Umbenennung des Ziels** ein (*„der Adopter darf es umbenennen"*), für die das Zielrepo keine beständige Stelle hat: `harness/mk/*.mk` ist tool-eigen und **konvergent** ([ADR-0007](../../docs/plan/adr/0007-bootstrap-phasen.md) Idempotenz-Klassen-Tabelle; [ADR-0033](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 4 führt dieselbe Klasse), der Wurzel-Aggregator ist konvergent und bindet kein adopter-eigenes `include` ein, und `archivierung.go` erklärt das Fragment selbst als konvergent. Benennt der Adopter das Ziel in beiden Dateien um, setzt der nächste Werkzeug-Lauf das Fragment kanonisch zurück, während die Anleitung `skip-if-present` ihren Namen behält: die Closure-Anleitung nennt dann ein `make`-Ziel, das im Repo nicht mehr existiert — [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine Ebene tiefer. | [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) · [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) §Adaptierbar · [ADR-0007](../../docs/plan/adr/0007-bootstrap-phasen.md) · [ADR-0033](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 4 | `internal/emit/templates/commands/close-welle.md:91` | nein — herstellbar nur über eine `full-smoke`-Variante (im Ziel umbenennen, `init` erneut fahren, Zielnamen von Anleitung und Fragment gegeneinander lesen); kein Gate hält die zwei Namen zusammen | adaptions-marker-nennt-eine-stelle-die-emissions-klasse-nicht-haelt |
| F-3 | LOW | Zwei neue Kommentare begründen ihre Aussage im **Konjunktiv über die verworfene Alternative**: `internal/emit/archivierung.go:18-20` (*„ohne das Fragment haette ein Ziel dort kein Kommando, das ihm das sagt — der Satz … staende in keiner Datei des Ziels"*) und als Doc-Kommentar desselben Satzes `internal/emit/archivierung_test.go:85` (*„Ein Ziel ohne Fragment haette dort gar kein Kommando"*) — das ist die Form, die [`AGENTS.md`](../../AGENTS.md) §3.7 als *Falsch* ausschreibt, an einem Kommentar, der eine der fünf Klassen daneben trägt (Abgrenzung: *„es teilt den Zweig des Traegers NICHT"*). Die Klasse steht im Bestand (`internal/emit/erfassung.go:15-16` führt denselben Konjunktiv für dieselbe Aussage), und ein Lauf dieser Welle hat der **reinen** Form derselben Klasse ein HIGH gegeben (Review-Report `slice-219`, 2026-09-12); die Abgrenzung zwischen *Klassen-Träger mit Konjunktiv-Schwanz* und *reiner Konjunktiv-Begründung* ist nicht gemessen und bleibt Architect-Sache. | [`AGENTS.md`](../../AGENTS.md) §3.7 („Falsch: … Konjunktiv über die verworfene Alternative") | `internal/emit/archivierung.go:18` · `internal/emit/archivierung_test.go:85` | nein — `make comment-claims` prüft, ob ein genannter Sensor existiert, nicht worüber ein Kommentar spricht ([`AGENTS.md`](../../AGENTS.md) §3.7) | kommentar-im-konjunktiv-ueber-die-verworfene-alternative |
| F-4 | INFO | Der E2E-Abschnitt **(c)** prüft die gates-Kette des Ziels **einseitig**: er verlangt, dass `archive-welle` in `make -n gates` nicht vorkommt, hat aber keine Vorbedingung darauf, dass die gelesene Kette überhaupt Einträge trägt — über einer leeren Kette bliebe die Prüfung grün. Der Go-Wächter derselben Aussage hat diese Vorbedingung (`internal/emit/archivierung_test.go:71-79` verlangt `record-gates`, `baseline-verify`, `docs-check` in der Hülle); für den E2E decken es die übrigen Abschnitte, die `make -j gates` im Ziel real fahren. | Maintainability | `harness/tools/full-smoke.sh:1078` | nein — herstellbar wäre es über eine Ziel-Fixture ohne `GATE_CHECKS`; kein Gate fährt das | negativ-pruefung-ohne-vorbedingung-auf-ihren-pruefbereich |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Die Zusage „kein Gate" am Baum** ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) | **geprüft, ohne Befund.** Das Fragment hängt **nichts** an `GATE_CHECKS` (`regelnIn` über die emittierte Datei, `archivierung_test.go:115`) und `archive-welle` liegt **nicht** in der transitiven Hülle des `gates`-Ziels (§1: Mutation `337` färbt genau diese zwei Zusicherungen rot). Der Hilfetext trägt die Kennzeichnung **in der Zeile selbst** (`archivierung.mk:27`, `— KEIN Gate`), in derselben Form wie das Muster `erfassung.mk:19` und wie die Spalte `Bindung` in `harness/README.md` §Werkzeuge (`kein Gate`). Die Begründung ist tag- und RANGE-frei und trägt **keinen** `LH-*`-Verweis — richtig, weil das Zielrepo die ID dieses Lastenhefts nicht führt. |
| **Die Sperren-Vererbung** ([`ADR-0033`](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 4) | **geprüft, ohne Befund; die Zusicherung trägt.** §4: `make full-smoke` **EXIT 0**; der Abschnitt bricht bei jeder verletzten Zusicherung mit 1 ab, prüft `Exit ≠ 0`, **beide** Marken `[untergrenze]`/`[haenger]` in der Ausgabe und dass `done/<welle>/` leer bleibt, und fährt denselben Aufruf danach ohne die zwei Auslöser real durch. §3: die vom Umsetzer selbst benannte Grenze ist exakt — `make` exitet **2**, die **3** steht in der Meldung; die Zusicherung hängt darum an der **Ausgabe** und nicht am Rezept-Exit, und sie behauptet nichts, was sie nicht liest. |
| **`close-welle.md`: Markerform und Wortgleichheit** ([`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) §Adaptierbar) | **geprüft, ohne Befund.** Die neue repo-spezifische Stelle trägt einen `ANPASSEN`-Marker in der Hausform (HTML-Kommentar, wie `close-welle.md:19` und die sechs Rollen-Typen); `TestCommands_AdaptationMarker` deckt seine Anwesenheit. Die Feststellungs-Zeile für ein Repo **ohne** das Werkzeug ist **wortgleich** geblieben: `git show 3e535c3c^:internal/emit/templates/commands/close-welle.md \| grep -c 'Hat dein Repo das Werkzeug nicht, ist die Bedingung nicht eingetreten; \*\*das\*\* gehört als'` → **1**, dieselbe Zählung über die Fassung nach dem Commit → **1**; die Zeile ist unverändert, nur umgebrochen. Der neue Text nennt **kein** `harness/tools/` (§7: **0** in allen drei Commands); die Verbots-Liste des Commands-Wächters (`make mutate`, `make smoke`, `test/mutations`, `ai-harness-init`, `slice-<Ziffern>`) hat über den neuen Zeilen **0** Treffer (`TestCommands_NoInternalLeak` gelesen, `make gates` grün). |
| **Die fünf Mutationsfälle `334`–`338`** ([`AGENTS.md`](../../AGENTS.md) §3.6) | **geprüft, mit zwei selbst gefahrenen Fällen ohne Befund.** `337` und `334` färben je den **benannten** Wächter rot, mit der im Fallkopf genannten Ursache (§1, §2). `335`, `336`, `338` sind **gelesen**, nicht gefahren: ihr Mechanismus trifft die Zusage unmittelbar (eine Kommentarzeile, deren Satz der Wächter wörtlich verlangt; eine Umbenennung, die das bats-Muster liest; eine `echo`-Zeile, deren Fehlen der E2E-Zweig grept), und die erklärte Stufe jedes Falls ist im Treiber definiert (`# verify: test-go` / `test-bats` / `full-smoke` gegen die Modus-Karte in `harness/tools/mutate.sh`). Die `# files:`-Angaben lösen je genau eine Datei auf; der `sed`-Anker von `334` trifft (`internal/emit/enforce.go:215`, nachgefahren). Die Querverweise der Fallköpfe auf Geschwister-Fälle (`Fall 180`, `183`, `186`, `261`) lösen als Dateien auf. **Kein voller `make mutate`** — er gehört auf die Post-Integration-Stufe (`.github/workflows/mutate.yml`; `v6.8.0` · `regelwerk/grundlagen-klassifikation.md` §Klassifikation). |
| **`TestArchivierungFragment_TraegtPreisUndMeldung` — Anker aus dem Kopfkommentar** (Klasse der Schwester-Runde `test-anker-aus-der-prosa-erfuellbar`) | **geprüft, ohne Befund — und die Begründung ist der Unterschied zum Schwester-Fall.** Vier der fünf Preis-Sätze sind nur im **Kopfkommentar** erfüllbar, der sechste (`der Traeger liegt nicht`) nur im Rezept; die Prüfung ist ein `strings.Contains` über die ganze Datei. Das ist hier **deckungsgleich mit dem Gegenstand**: [ADR-0033](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 5 verlangt den Preis *„in seinem Kopf"* als **geschriebenen Satz** — der Text ist das Gelieferte, nicht ein Stellvertreter für Verhalten. Die Verhaltens-Hälfte (fehlender Träger → Meldung, Exit 0) misst der E2E-Zweig (d) an der realen Ausgabe. Die Zusage *„bricht ab statt fremden Inhalt zu nehmen"* steht damit als **zugesagter Satz** im Ziel und ihr Verhalten im Träger — getrennt geprüft, getrennt belegt. |
| **[`AGENTS.md`](../../AGENTS.md) §3.7 über allen hinzugefügten Zeilen** | **geprüft, mit dem Befund F-3** und sonst ohne Befund: kein `Review-Befund`, keine Slice-Nummer als Erzählung, kein *„früher stand"*, kein Lauf-Protokoll, kein abgebrochener Satz. Die genannten Kennungen sind auflösbare Zeiger (`ADR-0033 Folgepflicht 8` existiert; `Fall 180/183/186/261` sind Dateien; `Rot-Gegenbeispiel: test/mutations/…` zeigt auf laufende Fälle — die Form des Bestands, `erfassung_test.go:473` führt sie gleich). Der Verweis auf `MR-005` und `LH-QA-01` steht dort, wo er hingehört — in den Kommentaren **dieses** Repos, nicht im emittierten Text. |
| **Rolle des Fragments gegen den Aggregator** ([`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) | **geprüft, ohne Befund.** Der Zielort `harness/mk/archivierung.mk` liegt unter dem Glob, den der emittierte Aggregator einbindet (`include harness/mk/*.mk` gelesen), die Datei entsteht **unbedingt** (§6), und die emittierte `.d-check.yml` führt kein `targets`-Modul — ein ungelistetes Ziel kann das Doc-Gate des Ziels also nicht rot färben. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** fremdes-rollen-artefakt-im-implementations-kontext ·
adaptions-marker-nennt-eine-stelle-die-emissions-klasse-nicht-haelt ·
kommentar-im-konjunktiv-ueber-die-verworfene-alternative ·
negativ-pruefung-ohne-vorbedingung-auf-ihren-pruefbereich

## Verdikt

**Merge-blockierend:** ja — HIGH (F-1) und MEDIUM (F-2). F-1 wird **nicht** herabgestuft: die Grenze
zwischen [`AGENTS.md`](../../AGENTS.md) §3.8 und der Ausnahme *„die emittierte Ebene"* in
[ADR-0028](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) ist ein
Rollen-Verdikt; es über den Konflikt-Pfad einzuholen ist der Weg, den `v6.8.0` ·
`regelwerk/modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz vorschreibt, und das Verdikt
ist ein Artefakt (Folge-ADR oder Register-Eintrag), keine Zuruf-Entscheidung. Fällt es zugunsten der
Gegenlesart aus, ist F-1 gegenstandslos und die Frage gehört als **dritter Teil** in
`BEO-ALL/anweisungssatz-eigentum-ohne-quelle` — dessen `state.md` führt heute nur die zwei
Spec-/Typkarten-Teile als offen, nicht die emittierte Ebene.

**Übergabe:** Findings gehen an den Implementer; F-1 zusätzlich an Planner und Architect (Konflikt-Pfad,
[`AGENTS.md`](../../AGENTS.md) §3.8). Die **Finding-Klassen** gehen in die Slice-Closure §7 und von dort
in den Zähler. Dieser Report selbst ist ein **Lauf-Beleg** — er wird über Läufe hinweg nicht wieder
gelesen und ersetzt keine Verifikation (Modul 11).

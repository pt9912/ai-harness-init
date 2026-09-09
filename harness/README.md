# Harness

## Purpose

Einstiegspunkt für Menschen und AI-Agenten. Kein Ersatz für spec/ oder
docs/. Bei Konflikt mit einer kanonischen Quelle gewinnt diese.

Strukturregeln leben in [`conventions.md`](conventions.md); die Adaptionen selbst liegen als je
eine Datei unter [`conventions/`](conventions/), und `conventions.md` ist ihr Index.

## Source precedence

3-Strata-Spec (Vertrag › Technik › Sicht, [`MR-019`](conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)):

| Rang | Datei | Charakter |
|---|---|---|
| 1 | [`spec/lastenheft.md`](../spec/lastenheft.md) | vertraglich abnahmebindend |
| 2 | [`spec/spezifikation.md`](../spec/spezifikation.md) | technisch verbindlich, ohne Vertragsänderung fortschreibbar |
| 3 | [`spec/architecture.md`](../spec/architecture.md) | Komponenten/Sequenzen, meilensteinfrei |
| 4 | [`docs/plan/adr/`](../docs/plan/adr/) | Architekturentscheidungen |
| 5 | [`docs/plan/planning/in-progress/roadmap.md`](../docs/plan/planning/in-progress/roadmap.md) | aktuelle Welle |
| 6 | [`docs/user/`](../docs/user/) *(falls vorhanden)* | Operations, Quality, Releasing |
| 7 | [`README.md`](../README.md) | Projekt-Überblick |
| 8 | [`AGENTS.md`](../AGENTS.md) | Agent-Briefing |
| 9 | diese Datei | Harness-Einstieg |

## Guides (Feedforward)

| Quelle | Inhalt |
|---|---|
| [`spec/lastenheft.md`](../spec/lastenheft.md) | Anforderungen, IDs, Akzeptanzkriterien |
| [`spec/spezifikation.md`](../spec/spezifikation.md) | technische Festlegungen: Defaults, Tracing-Felder, externe Fassungen |
| [`spec/architecture.md`](../spec/architecture.md) | Komponenten, Schichten, Constraints |
| [`docs/plan/adr/`](../docs/plan/adr/) | Architekturentscheidungen |
| [`AGENTS.md`](../AGENTS.md) | Hard Rules, Source Precedence |
| [`conventions.md`](conventions.md) | Strukturregeln, Index des MR-Blocks, Modus |
| [`conventions/`](conventions/) | die MR-Einträge selbst, eine Datei je Eintrag |

## Sensors (Feedback-Gates)

Nur existierende Targets (keine halluzinierten Gates):

| Target | Vertrag | Bindung |
|---|---|---|
| `make baseline-verify` | Vendored Baseline unverändert: Integrität **und** Vollständigkeit, netzlos | [`MR-007`](conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) |
| `make docs-check` | Doku-Referenzen grün (links/anchors/ids/codepaths), netzlos (`--network none`) — **im Prüfbereich seiner Module** (`codepaths` erreicht den vendored Baum nicht vollständig, s. u.) | [`MR-010`](conventions.md#mr-010--d-check-gate-fragment-tool-generiert) |
| `make test` | Command-Guard-Tests (bats) + Go-Unit-Tests (Dockerfile-`test`-Stage) grün | [`ADR-0004`](../docs/plan/adr/0004-durchsetzungs-emission.md), [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make lint` | Go-Lint (golangci-lint, Dockerfile-`lint`-Stage) grün | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make build` | Go-Binary cross-compiliert (Dockerfile-`build`-Stage) | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make shell-lint` | Shell-Hooks/-Helfer lint-clean (shellcheck) | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make ci-lint` | GitHub-Actions-Workflows syntax-clean (actionlint) | [`MR-014`](conventions.md#mr-014--ci-auf-frischem-klon-github-actions) |
| `make comment-claims` | Kommentar-Behauptungen nennen ihren Sensor; genannte Tests existieren — **im Prüfbereich**, und der ist enger als der Gate-Stempel (s. u.) | [`AGENTS.md`](../AGENTS.md) §3.6 |
| `make host-bin` | Träger (Produkt-Binär) für die **Host**-Plattform gebaut und im gitignorierten Zustands-Bereich abgelegt (Docker-only, GOOS/GOARCH aus `uname`) | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make span-check` | Träger vorhanden **und** sein Unterkommando `span-emit` funktionsfähig; Ablageort real `git check-ignore`-geprüft | [`spec/spezifikation.md`](../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 |
| `make gates` | alle aktuell lauffähigen Gates | — |

Der Dogfood-Go-Gate-Stack ist **vollständig**: `make lint` / `make build` / `make test` (Go via Dockerfile-Stages, slice-001a/b) neben `docs-check` / `shell-lint` / `baseline-verify`. **Nicht behauptet**: das Architektur-Gate (a-check, [`LH-FA-07`](../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) — der Dogfood ist **flach**, hier hätte a-check einen leeren Prüfbereich ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). **Emittiert wird es trotzdem** (slice-046, emitted-only): ein Zielrepo mit einem **schichten-tragenden** Layout — heute `--arch hexslice` (go, cpp) oder `--arch hexagonal` (go) — bekommt `.a-check.yml` + `a-check.mk` + sein Gate-Fragment und fährt a-check in seinem `make gates` mit; ein flaches Ziel bekommt keines. Welche Layouts das sind, entscheidet **keine Namensliste**, sondern die strukturelle Frage, ob das Layout eine geprüfte Schicht trägt. Belegt in `make full-smoke` (beide Richtungen + ein verbotener Import, der das emittierte Gate rot färbt), nicht hier.

**Was das Modul `planning` in `docs-check` deckt, und was nicht** (slice-125): `.d-check.yml`
bindet `heading`/`marker` auf den Abschnitt „## Offene Wellen" der Roadmap
([`docs/plan/planning/in-progress/roadmap.md`](../docs/plan/planning/in-progress/roadmap.md)) und
hält damit die **Marker-Hälfte** — der Ruhe-Marker „Nichts in Arbeit." steht dort genau dann, wenn
[`docs/plan/planning/in-progress/`](../docs/plan/planning/in-progress) keinen `slice-*.md` trägt;
ein Widerspruch färbt `docs-check` rot (Grund-Code `planning-drift`). Die **Listen-Hälfte** — die
Bijektion zwischen den Zeigern unter „Offene Wellen" und den flachen Welle-Dateien — bleibt
unbewacht: Die `waves`-Fähigkeit desselben Moduls verlangt unter `waves.mode: many` genau diese
Bijektion (Default ist `one`, ein Singleton-Prädikat) und kennt in beiden Modi die in der Roadmap
selbst dokumentierte Abweichung dieses Repos nicht — eine Welle-Datei wird hier geschnitten,
**bevor** ihr Start-Trigger eintritt, und `waves` meldete das als `wave-drift`/
`wave-preview-exists`, obwohl es hier die gewollte Form ist. `waves` bleibt deshalb aus; die
Fähigkeit dazuzuschalten setzt voraus, dass diese Abweichung selbst aufgelöst wird (Ziel-Form statt
Repo-Konvention), was dieser Slice nicht entscheidet. Die zweite Fähigkeit desselben Moduls
(`closure`, Struktur der Closure-Notizen) ist seit slice-129 aktiviert — was sie deckt und was
nicht, steht im eigenen Absatz unten. Eine **vierte** Fähigkeit desselben Moduls (`observations`,
Deckung zwischen zitierten Beobachtungs-Kennungen und ihrem Nachweis im Register — additiv eine
fünfte für den Verzeichnis-Modus dieser Ablage) ist ebenfalls verfügbar und nicht aktiviert; anders
als `closure` trägt sie — wie `waves` selbst — noch keinen eigenen Slice —
[`BEO-ALL/register-paarung-ohne-gate-modul`](../docs/plan/planning/observations/BEO-ALL/register-paarung-ohne-gate-modul/observation.md)
führt die Lücke als offene Beobachtung, mit einer Drift-Log-Zeile in
[`roadmap.md`](../docs/plan/planning/in-progress/roadmap.md) daneben.

**Was `closure` (zweite Fähigkeit von `planning`) deckt, und was nicht** (slice-129):
[`.d-check.yml`](../.d-check.yml) setzt `planning.closure.dir: docs/plan/planning/done` und hält
damit Abschnitt 7 (Closure-Notiz) jedes Kandidaten gegen die Fähigkeit des Moduls: kein Abschnitt,
der auf das Default-Muster `^#{2,3} .*Closure-Notiz` passt (`closure-note-missing`), mehrere
passende Überschriften ohne eindeutigen Abschnitt (`closure-note-ambiguous`, immer aktiv), weniger
als vier Satzenden außerhalb von Code (`closure-note-thin`, mit Datei und Zeile in der Meldung),
ein unausgefüllter `<feld>`-Platzhalter (`closure-note-placeholder`, Bedingung `placeholder: true`)
und eine deklarierte Floskel (`closure-note-boilerplate`, Bedingung `boilerplate: […]`). **Rot
gesehen, gegen eine Kopie außerhalb des Repos, netzlos, Mount `:ro`, derselbe Digest wie
`docs-check`:**

```sh
DIGEST=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)
git archive HEAD | tar -x -C <kopie>
docker run --rm --network none -v <kopie>:/repo:ro "ghcr.io/pt9912/d-check@$DIGEST" \
  --enable planning --config /repo/.d-check.yml
# unveraendert:                 … 0 Befund(e)
# Abschnitt 7 einer done/-Datei auf einen Satz gekuerzt:
#   …/slice-001a-cli-skeleton.md:79  closure-note-thin  Closure-Notiz traegt 1 Satzende-Zeichen
#   ausserhalb von Code-Bloecken, verlangt sind 4
```

**Der Kandidaten-Filter bleibt der Modul-Default `slice-glob`** — `.d-check.yml` setzt kein eigenes
`glob:` — und trifft damit nur `slice-*.md`
(`ls docs/plan/planning/done/slice-*.md | wc -l`, kein Erwartungswert, wandert mit dem Bestand). Die
Welle-Ebene (`ls docs/plan/planning/done/welle-*.md | wc -l`) bleibt **absichtlich** außen vor: Die
Welle-Closure dieses Repos liegt auf zwei Dateien verteilt — dem flachen Welle-Plan und seiner
Ergebnisnotiz `done/welle-NN-results.md` —, das ist die Form, die
`modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 3 selbst vorschreibt (*„Und die
Welle-Plan-Datei wandert per `git mv` von flach nach `done/`"*, dort neben der eigenen
Closure-Notiz). Der flache Welle-Plan trägt in seinem §7 nur den *Zeiger* auf die Ergebnisnotiz
(zwei Sätze, unter der Schwelle); die Ergebnisnotiz selbst führt ihre Closure-Aussage bei **8** der
**12** Wellen als **H1** (statt der vom Modul erwarteten H2/H3) — `grep -lE '^# .*[Cc]losure'
docs/plan/planning/done/welle-*-results.md | wc -l` → **8**. Die übrigen vier
(`welle-06`, `welle-07`, `welle-08`, `welle-12`) tragen als H1 *„… — Results-Notiz"* und führen das
Wort *Closure* in **keiner** Überschriften-Ebene (`grep -cE '^#{1,6} .*[Cc]losure'` → 0 je Datei) —
sie weichen damit auch von der vendored Ziel-Form ab
(`.harness/baseline/v6.5.0/templates/docs/plan/planning/welle-results.template.md:1`) und bleiben
eine benannte, nicht nachgezogene Abweichung, kein zweiter Grund für den engen Filter. Gegen eine
Kopie außerhalb des Repos, netzlos, mit `closure.glob: '*.md'`
probeweise geweitet
(`docker run --rm --network none -v <kopie>:/repo:ro ghcr.io/pt9912/d-check@<digest> --config /repo/.d-check.yml --enable planning`,
`<digest>` aus `d-check.mk`): **20** Befunde — **12** `closure-note-missing` (jede
`welle-NN-results.md`) und **8** `closure-note-thin` (acht der zwölf Welle-Pläne, ihr
§7-Zeiger). Kein Erwartungswert, beide Zahlen wandern mit dem Welle-Bestand — tragend ist die
**Zusammensetzung**: Beide Klassen entstehen überwiegend aus derselben Zwei-Datei-Form, nicht aus
fehlender Substanz; die vier H1-Abweichungen oben sind darin enthalten, aber keine eigene Ursache.
Der Filter bleibt eng, statt den Gate über eine Form rot zu färben, die diese Welle-Closure
absichtlich wählt.

`placeholder` bleibt aus derselben Zurückhaltung aus: eingeschaltet meldet der Basis-Lauf **einen**
`closure-note-placeholder`
(`docs/plan/planning/done/slice-087-emittierte-doku-tische-init-invariant.md:353`) — eine
Vorlagen-Syntax in escapten Backticks, deren ungerade Backtick-Zahl die Inline-Code-Paarung
verschiebt (eine Vorverarbeitungs-Grenze, die das Werkzeug selbst führt), kein unausgefüllter
Rumpf. Die Bedingung anzuschalten hieße, ein Zeitdokument zu ändern oder eine Ausnahme für eine
Datei zu setzen, die nichts falsch macht — beides schlechter als sie auszulassen.

**Der Lauf hängt am geteilten Durchsetzungspunkt `make gates`**, nicht an einem eigenen Profil. Das
Benutzerhandbuch des Werkzeugs legt für diese Fähigkeit ein eigenes `--config`-Profil nahe, damit
nicht jeder gewöhnliche Doc-Lauf die Closure-Notizen mitprüft. Dieses Repo hat **einen**
Durchsetzungspunkt (`docs-check` in `make gates`), und `closure` läuft im selben `planning`-Block
wie die Marker-Hälfte oben — ein zweites Profil wäre ein zweiter Ort, an dem dieselbe Modul-Config
driften kann, dieselbe Klasse, die [`MR-010`](conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
für das Gate-Fragment schon einmal ausbuchstabiert hat. **Was das nicht leistet:** Jeder
`docs-check`-Lauf öffnet jetzt auch jede `slice-*.md`, die **flach** unter `done/` liegt, und prüft
ihre §7-Struktur — auch dann, wenn die Änderung, die den Lauf auslöst, mit `done/` nichts zu tun
hat; ein dediziertes Advisory-Target, das nur die Closure-Prüfung fährt, ohne die übrigen sechs
aktiven Module, gibt es nicht.

**Der Prüfbereich greift nicht rekursiv, und das ist heute folgenlos, morgen nicht mehr.**
`closure.dir` öffnet nur die Kandidaten **im genannten Verzeichnis selbst**; eine identische, dünne
Notiz in einem Unterverzeichnis erzeugt **keinen** Fund — gemessen an einem Sonden-Paar (dieselbe
`§7`-gekürzte Datei einmal flach unter `done/`, einmal unter einem synthetischen
`done/welle-99/`): flach `closure-note-thin`, tief **0** Treffer, in derselben Kopie außerhalb des
Repos. `done/` trägt heute keine Unterverzeichnisse (`find docs/plan/planning/done -mindepth 1
-maxdepth 1 -type d | wc -l` → 0), die Zusage ist also **heute** vollständig — die vom
Regelwerk (`.harness/baseline/v6.5.0/regelwerk/modul-06-roadmap.md` §Wellen-Closure-Prozedur
Schritt 4) **vor der ersten Archivierung** verlangte Geltungsbereichs-Prüfung gilt für diesen
Sensor als hiermit durchgeführt
und mit **benannter Grenze** beantwortet, statt stillschweigend zu bestehen: sobald ein
`make archive-welle`-Lauf (Werkzeug in Bau, [ADR-0033](../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md))
Slice-Stubs in ein `done/<welle-id>/`-Unterverzeichnis bewegt, deckt dieser Sensor sie nicht mehr —
und die Stubs tragen nach der Ziel-Form ohnehin kein volles §7 mehr, sind also für `closure` kein
sinnvoller Kandidat. Wer `archive-welle` produktiv nimmt, zieht den Geltungsbereich hier nach
oder benennt an dieser Stelle, dass die Zusage ab dann nur für den flachen Bestand gilt.

**Was `codepaths` an toten Pfaden in den vendored Baum nicht sieht**
([slice-201](../docs/plan/planning/done/slice-201-codepaths-erreicht-den-vendored-baum-nicht.md)):
`codepaths.roots: [spec, docs, harness]` ist eine Liste von Wurzel-**Präfixen** — ein
Inline-Code-Pfad wird nur existenzgeprüft, wenn er mit einem dieser drei Strings oder mit
`./`/`../` beginnt. Ein Pfad unter `.harness/baseline/` beginnt mit `.harness`, nicht mit
`harness`, und liegt damit außerhalb dieser Liste: ein erfundener Dateiname dort bleibt stumm,
derselbe erfundene Dateiname unter `harness/` färbt `codepath-missing` — gemessen an einem
hermetischen Sonden-Paar über dem in [`d-check.mk`](../d-check.mk) gepinnten Digest. Ein toter
Inline-Baseline-Pfad in einem **lebenden** Artefakt (etwa
[`harness/conventions.md`](conventions.md)) bleibt darum dauerhaft gate-unsichtbar.

**Die naheliegende Reparatur — `.harness` als vierten Präfix aufnehmen — ist gemessen und
verworfen, nicht übersehen:**

```sh
DIGEST=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)   # v0.74.1 zum Zeitpunkt dieser Messung
git clone --local --no-hardlinks . /tmp/probe-fresh    # keine .harness/state/, wie ein frischer Klon
sed -i 's/roots: \[spec, docs, harness\]/roots: [spec, docs, harness, .harness]/' /tmp/probe-fresh/.d-check.yml
docker run --rm --network none -v /tmp/probe-fresh:/repo:ro "ghcr.io/pt9912/d-check@${DIGEST}" \
  | tee /tmp/lauf.txt | grep -c codepath-missing   # 128 -- kein Erwartungswert, wandert mit dem Bestand;
                                                     # gemessen über demselben Baum, der diesen Absatz enthält
```

**128** zusätzliche Befunde — wie jede Zahl unten aus derselben Kommando-Kette gewonnen und
darum ebenso **kein Erwartungswert**, sondern derselbe wandernde Bestand. **102 davon** liegen in
drei Klassen, die kein Bug sind:
content-gefrorene Verweise auf abgelöste Baseline-Tags in den einzelnen
`harness/conventions/`-Einträgen (append-only seit
[`MR-020`](conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)/[`MR-032`](conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger))
und in denselben Tag-Ständen zitierenden, nach [`AGENTS.md`](../AGENTS.md) §3.4 eingefrorenen ADRs
· Pfade eines abgelösten Mechanismus (unter `.harness/cache/`, abgelöst von
[`MR-007`](conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) · der
gitignorierte Laufzeit-Ort `.harness/state/`, den [`spec/architecture.md`](../spec/architecture.md)
und [`spec/spezifikation.md`](../spec/spezifikation.md#5-metriken-und-tracing-felder) als
kanonische Adresse führen, obwohl er auf einem frischen Checkout nicht existiert:

```sh
grep codepath-missing /tmp/lauf.txt | awk -F'\t' '$2 ~ /^\.harness\/(baseline|state|cache)/' | wc -l   # 102
grep codepath-missing /tmp/lauf.txt | awk -F'\t' '$2 !~ /^\.harness\/(baseline|state|cache)/' | wc -l  #  26
```

Ein Prüfer, der nur den gesuchten Fall trifft — einen toten Pfad unter dem **aktuellen**
Baseline-Tag in einem lebenden Artefakt —, bräuchte für jede dieser drei Klassen eine eigene,
gemessene Ausnahme: dieselbe Apparatur, die
[`ADR-0039`](../docs/plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) für die
**Link**-Form von genau drei einfrierenden Bäumen gebaut hat, hier aber zusätzlich für eine
vierte, nicht einfrierende Klasse (gitignorierte Laufzeit-Pfade in kanonischen Spec-Dokumenten).
Das ist außerhalb des Umfangs eines einzelnen Slice und bleibt eine **benannte Lücke**: ein toter
Inline-Pfad unter `.harness/baseline/` in einem lebenden Artefakt bleibt gate-unsichtbar, bis
[slice-202](../docs/plan/planning/open/slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer.md)
diese Ausnahme-Klassen einzeln trägt.

**Die 102 sind nicht die ganze Entlastung.** Unter den 30 Treffern, deren Ziel mit
`.harness/baseline/` beginnt —

```sh
grep codepath-missing /tmp/lauf.txt | awk -F'\t' '$2 ~ /^\.harness\/baseline\//' | wc -l   # 30
```

— liegen nicht alle in `harness/conventions/` oder einer eingefrorenen ADR:

```sh
grep codepath-missing /tmp/lauf.txt | awk -F'\t' '$2 ~ /^\.harness\/baseline\//{split($1,a,":"); print a[1]}' \
  | grep -vE '^(harness/conventions/|docs/plan/adr/)' | sort -u
```

Unter den 30 zählt der Rest **sechs** Fundstellen, nicht null: fünf tragen einen
`.harness/baseline/<abgelöster Tag>/…`-Pfad in einem offenen Slice-Plan bzw. einem Welle-Plan; eine
sechste — außerhalb der `.harness/baseline/`-Form, aber derselben Klasse *toter Pfad in einem
lebenden Artefakt* — verweist aus einer Skill-Datei auf eine eigene, nicht existierende Vorlage.
(Zwei weitere Treffer derselben Filterzeile sind **kein** Bug: der Beleg-Pfad, den dieser Absatz
selbst zu Testzwecken erfindet, und ein `$(BASELINE_TAG)`-Platzhalter in einer Rezept-Beschreibung
anderswo in diesem Dokument — beide sind erkennbar kein Tag-Literal.) Das ist wörtlich der oben
benannte tragende Fall — kein Rauschen.

**Dieselben sechs sind nicht der ganze Rest der 26** — jene Filterzeile trifft nur, wessen Ziel mit
`.harness/baseline/` beginnt. Im **gesamten** Rest von 26 liegen sechs weitere Treffer mit
demselben Ziel — einer im Repo nicht existierenden Skill-Datei (`ls .harness/skills/` → nur
`reviewer.md`) —, in der laufenden Roadmap, zwei offenen Slice-Plänen und drei flachen, offenen
Welle-Plänen:

```sh
grep codepath-missing /tmp/lauf.txt \
  | awk -F'\t' '$2 == ".harness/skills/closure-note-reviewer.md"' \
  | grep -vE 'done/|docs/plan/adr/' | wc -l   # 6 -- kein Erwartungswert, wandert mit dem Bestand
```

Zusammen mit den sechs oben sind es **zwölf**, nicht sechs:

```sh
grep codepath-missing /tmp/lauf.txt \
  | grep -v '^docs/plan/planning/done/' | grep -v '^docs/plan/adr/' | grep -v '/evidence/' \
  | grep -v '^harness/conventions/' | awk -F'\t' '$2 !~ /^\.harness\/(state|cache)/' \
  | grep -v 'does-not-exist-201' | grep -v '\$(BASELINE_TAG)' | wc -l   # 12
```

Beide Gruppen bleiben hier **ungezogen und benannt**, statt in diesem Slice mitgenommen zu werden:
Die zwölf Fundstellen liegen in mindestens vier verschiedenen Eigentums-Bereichen (offene
Slice-Pläne, flache Welle-Pläne, die laufende Roadmap, eine nach
[ADR-0028](../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
Reviewer-eigene Skill-Datei), und ein Nachzug in einem einzelnen Implementations-Lauf griffe über
mehrere Rollen-Grenzen hinweg — genau der Fall, den
[slice-201](../docs/plan/planning/done/slice-201-codepaths-erreicht-den-vendored-baum-nicht.md)
§1 mit *„findet sie viele, ist das ein eigener Vorgang"* für den Gesamtbestand vorwegnimmt, hier
schon bei zwölf Fundstellen, weil die Eigentums-Grenze und nicht die Stückzahl den Ausschlag gibt.

**Was `comment-claims` nicht deckt — benannt, weil eine Vollständigkeits-Zeile („N Datei(en) geprueft, 0 Befund(e)") sonst mehr behauptet als sie trägt** (Review-Befund HIGH-1 vom 2026-07-30; die hier zuerst stehende Zählung „an **zwei** Stellen" war selbst zu eng und ist in Runde 2 korrigiert worden): der Prüfbereich entsteht im Rezept aus `git ls-files` und ist an **drei** Stellen enger als der Gate-Stempel, den `record-gates` über den Arbeitsbaum legt (`harness/tools/working-tree-hash.sh`: `--cached --others --exclude-standard`).

1. **Nur der Index.** `git ls-files` ohne `--others`: eine neu angelegte, noch **untrackte** Datei liegt innerhalb des bestätigten Baum-Zustands und außerhalb des Prüfbereichs — sie wird erst nach ihrem ersten `git add` geprüft.
2. **Nur vier Pfad-Muster** — `internal/**/*.go`, `cmd/**/*.go`, `harness/tools/*.sh`, `.claude/hooks/*.sh`. Dauerhaft draußen liegen damit u. a. `Makefile`, `harness/tools/*.awk`, `internal/emit/templates/`, `test/`, `.codex/`, `.github/` und **jede** Markdown-Datei.
3. **Test-Dateien ausgenommen** (`_test.go`) — ein Kommentar dort behauptet keine Abdeckung, sondern *ist* eine.

**Nur (1) heilt ein `git add`; (2) und (3) sind permanent.** Wie groß der Ausschnitt ist, sagt der Gate in seiner letzten Zeile selbst (am 2026-07-30: 38 Dateien, 19 Go + 19 Shell); wie groß der Stempel ist, sagt `git ls-files --cached --others --exclude-standard`. **Eine eingefrorene Gegenüberstellung steht hier bewusst nicht** — sie wäre beim nächsten Commit falsch, dieselbe Falle wie bei der Span-Zählung in [`spec/spezifikation.md`](../spec/spezifikation.md#5-metriken-und-tracing-felder) §5. Wer eine Datei **in einem der vier Muster** neu anlegt und ihre Zusagen gedeckt sehen will, lässt den Gate **nach** dem `git add` laufen; wer eine `harness/tools/*.awk`, ein `Makefile`-Rezept oder eine Vorlage unter `internal/emit/templates/` schreibt, bekommt **gar keine** Prüfung — dort trägt allein das Review.

**Ein zweites, gemessenes Loch derselben Klasse — hier benannt, nicht nebenbei geschlossen:** die Negations-Ausnahme in `harness/tools/comment-claims.sh` lässt einen Satz durch, der eine Abdeckung *verneint*; ihr Fenster ist zwölf Zeichen breit. Ein Lauf über das (außerhalb liegende) `Makefile` meldet genau einen Treffer, und dort stehen zwischen „belegte" und „nicht" **dreizehn** Zeichen — die Ausnahme verfehlt ihn um ein Zeichen. Ob das Fenster weiter gehört oder der Satz umgeschrieben, entscheidet der Slice, der den Mechanismus anfasst.

Der Mechanismus selbst ist hier **nicht** geändert (Gate-*Anheben* ist ein Steering-Loop nach [`MR-001`](conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids), und er betrifft jede künftige neue Datei, nicht die Telemetrie) — er wartet auf einen eigenen Schnitt.

**CI** ([`MR-014`](conventions.md#mr-014--ci-auf-frischem-klon-github-actions), slice-027): GitHub Actions fährt `make gates` + `make smoke` + `make mutate` auf **frischem Klon** pro Push/PR — schließt die [`MR-003`](conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Restlücke (der lokale Stop-Hook gibt einen cleanen Tree ohne State frei; „CI ist dort das Netz") und gibt `make mutate` seinen mechanischen Pro-Push-Auslöser. Die **Netz-Sensoren** `regelwerk-check`/`baseline-freshness` laufen **nur nächtlich** — ein Upstream-Ausfall darf keinen Push blockieren. Die CI ruft **ausschließlich `make`-Targets** (keine zweite Gate-Definition). **Was CI nicht prüft:** nichts, was nicht in einem dieser Targets steht — ein grüner CI-Lauf ist keine Aussage über ungetestete Flächen.

`make history-range-guard RANGE=<base>..<head>` (oder `STAGED=1`) ist der **Vorlauf-Wächter** vor einem history-lesenden d-check-Modul-Lauf (`vcs`/`commits`, Targets `doc-immutable`/`doc-commits` in `d-check.mk`) — **kein Gate, in keiner Prerequisite-Kette**: er prüft eine Vorbedingung *für einen Job*, nicht den Zustand des Repos ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). **Der Anlass:** `actions/checkout` klont per Default mit Tiefe 1; eine dabei *auflösbare, aber leere* Range (z. B. `HEAD..HEAD`) meldet d-check ohne diesen Wächter `0 Befund(e)`, Exit 0 — blind und grün, statt zu fallen ([`MR-007`](conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 3). Eine *unauflösbare* Basis (z. B. `HEAD~1` in einem Tiefe-1-Klon) deckt der Wächter **nicht zusätzlich** — d-check selbst bricht dafür schon mit Exit 2 ab, und ein Wächter, der nur das fängt, prüfte eine Eigenschaft, die das Werkzeug bereits hält. Geprüft wird darum die **Range** (`git rev-list --count`), nicht die Klon-Tiefe. **`STAGED=1` prüft keine Range**, sondern vergleicht den Index gegen `HEAD` (`git diff --cached`): fehlt jede gestagte Änderung, meldet der Wächter das explizit (`--staged ohne gestagte Aenderung — nichts zu pruefen.`) statt schweigend mit Exit 0 zu enden; findet sich mindestens eine, bleibt die Ausgabe leer und der Exit-Code in beiden Fällen 0 — den Inhalt der gestagten Änderung prüft dann das d-check-Modul selbst, nicht dieser Wächter. `.d-check.yml` aktiviert für `docs-check` selbst nur `links, anchors, ids, matrix, codepaths, spans, planning`, keines davon liest Historie — ein history-lesender Job braucht `fetch-depth: 0` an seinem Checkout **und** diesen Wächter davor. Die Entscheidungslogik (`decide()`/`decide_staged()`) ist von ihren `git`-Aufrufen getrennt und über `--decide <range> <count>` bzw. `--decide-staged <0|1>` hermetisch mit Fixture-Werten testbar (`test/history-range-guard.bats`) — das gepinnte `BATS_IMAGE` führt kein `git` (wie bei `slice-mv`/`archive-welle`); der reale Beleg an einem echten flachen Klon bzw. am echten Index steht im Skriptkopf (`harness/tools/history-range-guard.sh`, Abschnitt BELEG).

`make adr-immutable RANGE=<base>..<head>` (oder `STAGED=1`) kettet diesen Wächter vor den
eigentlichen `vcs`-Modul-Lauf (`make doc-immutable`, `d-check.mk`) — **wie `history-range-guard`
kein Gate, in keiner Prerequisite-Kette**, denn die Range variiert pro Aufruf und ist damit kein
hermetischer Prüfbereich ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
Geprüft wird [`AGENTS.md`](../AGENTS.md) §3.4: der Kern einer über die Range `Accepted`
gebliebenen ADR ändert sich nicht. Der `vcs:`-Block in `.d-check.yml` ist gegen den **gelebten**
Bestand gesetzt, nicht gegen den Vorschlag aus `d-check --print-config` — die Abweichungen
tragen die Zusage und sind an einem Wegwerf-Klon außerhalb des Repos gemessen, nicht
angenommen: `exclude-sections: [Geschichte]` nimmt den Abschnitt aus dem Kern, in dem eine ADR
ihre Fortschreibung führt — jede ADR dieses Repos endet mit `## Geschichte`, und ohne die
Ausnahme färbte jede Fortschreibung statt nur eine Kern-Änderung rot. `head-allow` ist **voll
verankert** (`^…$`, kein Präfix-Match — ein Zusatz hinter `Accepted`, etwa
„Accepted (überholt, siehe ADR-NNNN)“, färbt seit diesem Anker rot statt durchzurutschen) und
trägt drei Werte: `Accepted` unverändert, `Deprecated` (Vokabular der ADR-Vorlage und von
[`docs/plan/adr/README.md`](../docs/plan/adr/README.md), Ausgang ohne Nachfolger) und die im
Bestand gelebte Link-Form des Supersede-Übergangs (`Superseded by [ADR-NNNN](NNNN-titel.md)`) —
nicht die vom Werkzeug vorgeschlagene bare Kennung, und nicht die vom Index ebenfalls geführte
bare Supersede-Form (`Superseded by ADR-NNNN` ohne Klammern): Letztere bleibt ausgeschlossen, aber
**nicht**, weil ein anderes Modul sie ohnehin fängt — gemessen ist das Gegenteil: `ids`
(`link-policy: always` auf `ADR-\d{4}`) prüft Kennungen nur **außerhalb** ihres eigenen
Zieldateibaums `docs/plan/adr/`. Dieselbe bare Erwähnung (`echo 'Text mit bare ADR-0005.' >>
<datei>`, ein Commit, `make docs-check`) trifft in `docs/plan/planning/in-progress/roadmap.md`
`id-unlinked` (1 Befund), in einer Datei unter `docs/plan/adr/` `0 Befund(e)`. `head-allow` ist
an dieser Stelle die **einzige** Durchsetzung der im Bestand gelebten Link-Form, kein redundanter
zweiter Schutz.
`status-line` markiert, welche Zeile diesem `head-allow` statt der vollen
Kern-Unveränderlichkeit unterliegt; ohne sie fällt die Statuszeile in den Kern und jeder erlaubte
Übergang färbt rot. `test/vcs-modul-wiring.bats` hält alle vier Felder gegen Regression, ohne
selbst einen Docker-Lauf zu fahren; was `vcs` **kann**, bleibt eine gemessene Eigenschaft des
vendored Werkzeugs und keine dieses Repos.

**Ein Aufrufer existiert:** der Job `adr-immutable` in `.github/workflows/ci.yml` bestimmt die
Range ereignisabhängig — bei `pull_request` Base gegen Head, bei `push` den vorherigen
Ref-Stand (`github.event.before`) gegen den neuen — und überspringt einen Push ohne vorherigen
Stand (neuer Branch, `before` ist die Nullreferenz), statt eine Basis zu erfinden. Sein Checkout
trägt `fetch-depth: 0`; alle übrigen Checkouts des Repos bleiben bei der Default-Tiefe
(Begründung im Kopf von `.github/workflows/ci.yml`).

**Ein reiner `git mv` einer ADR-Datei ist gemessen, nicht offen:** Das Modul trennt ihn **nicht**
von einer Kern-Änderung — es zählt Pfad-Stabilität zur Immutabilität. Gegen einen Wegwerf-Klon,
ein Commit, der eine `Accepted`-ADR ohne Inhaltsänderung umbenennt:

```sh
git mv docs/plan/adr/0003-go-native-binaries.md docs/plan/adr/0003-umbenannt.md
git commit -qm "reiner git mv einer Accepted-ADR"
make adr-immutable RANGE=<base>..HEAD
# docs/plan/adr/0003-go-native-binaries.md:1  core-drift-vcs
#   immutable Datei geloescht oder umbenannt — der Pfad einer immutablen Datei ist stabil
```

Operativ folgenlos bleibt das heute: ADR-Pfade sind ortsfest, und
[`AGENTS.md`](../AGENTS.md) §3.11 nimmt sie ausdrücklich von der wandernden Klasse aus — ein
realer `slice-mv`-artiger Umzug einer ADR-Datei ist in diesem Repo nicht vorgesehen. Träte er ein,
wäre der Fehlalarm hier der Beleg dafür, dass die Bewegung als zwei Commits (Hard Rule 3.3) allein
nicht reicht: `vcs` bräuchte eine eigene Ausnahme für den reinen Move, die es heute nicht gibt.

**Was innerhalb von `## Geschichte` stehen darf, ist entschieden, nicht offen gelassen.** Die
Ausnahme ist die Voraussetzung dafür, dass der Sensor an der Kopfzeile statt am Dateiende
anschlägt (s. o.); sie kostet, dass ein Absatz, der dort statt in einer Folge-ADR landet,
unbewacht bleibt. Der Umfang der so ungeschützten Fläche ist gemessen und wächst mit jeder
Fortschreibung:

```sh
t=0; g=0; for f in docs/plan/adr/[0-9]*.md; do
  t=$((t+$(wc -c < "$f"))); g=$((g+$(awk '/^## Geschichte/{i=1} i' "$f" | wc -c))); done
awk -v a=$g -v b=$t 'BEGIN{printf "%d von %d Bytes = %.1f%%\n", a, b, 100*a/b}'   # 8.0 % im Schnitt, bis 28,1 % je Datei
```

Die Alternative — `exclude-sections: []` — ist keine engere, sondern eine strengere Variante mit
einem anderen Fehler: Jede ADR dieses Repos endet mit `## Geschichte`; ohne die Ausnahme würde
**jede** Fortschreibung einer angenommenen ADR rot färben, nicht nur eine Kern-Änderung — 100 %
der heutigen Fortschreibungen wären Fehlalarme gegen 0 gemessenen normativen Sätzen im
Geschichte-Abschnitt heute (`git grep -n 'Revidiert (Teil-Supersede)' -- 'docs/plan/adr/0*.md'`
gegen die Zeilennummer von `^## Geschichte` derselben Datei zeigt: die drei bestehenden
Teil-Supersede-Anordnungen liegen im geschützten Kern, keine im Geschichte-Abschnitt). `vcs`
kennt keine dritte, feinere Stufe — der Schlüssel schließt einen benannten Abschnitt vollständig
aus dem Kern oder gar nicht, eine partielle (append-only) Prüfung bietet das Modul nicht. Dieses
Repo trägt deshalb bewusst die zweite Fehlform (ein still bleibender Verstoß ist möglich, aber
heute nicht eingetreten) statt der ersten (ein Gate, das bei jeder legitimen Fortschreibung
blockiert): Die Kosten der ersten sind sicher und laufend, die der zweiten sind hypothetisch und
liegen bei der Review-Disziplin ([`AGENTS.md`](../AGENTS.md) §3.7 für den Kommentar-Fall,
[`docs/plan/adr/README.md`](../docs/plan/adr/README.md) für den Zusatz-Umfang einer
Teil-Supersede-Anordnung).

**Eine Grenze bleibt offen, benannt statt geschlossen:** ob `vcs` dieselbe
`exclude-sections`-Liste wie `matrix` braucht (`[Historie, "7. Historie", Geschichte]`), ist
geprüft, aber nicht übernommen, solange kein ADR-Kopf eine dieser zwei zusätzlichen
Überschriften trägt.

**Nicht-Gate-Verify** (verfügbar, **nicht** in `make gates` — wie `regelwerk-check`/`baseline-freshness`): `make smoke` ist der Tier-2-Emit-Smoke (slice-002) — es emittiert die Doc-Gate-Baseline in ein tmp-Repo und lässt das emittierte `docs-check` real laufen (Host-Docker, ggf. Netz-Pull). `make full-smoke` ist der **Voll-E2E-Smoke** (slice-024): Bootstrap in ein tmp-Repo, dann dort der **zusammengeführte** `make gates` ([`MR-010`](conventions.md#mr-010--d-check-gate-fragment-tool-generiert): docs-check + Go-Gates in einem Lauf) — der Happy-Path-Beweis ([`LH-FA-01`](../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)), dass ein frisch gebootstrapptes Repo out-of-the-box grün fährt (die Nutzer-Sicht, die `make smoke` mit seinen getrennten Schritten nicht nimmt). **Sein Grün sagt das eine, sein Rot sagt zwei Dinge:** der Lauf fragt je Durchgang fremde Registries nach gepinnten Bildern und macht jede dieser Anfragen zur Bedingung seines Grüns. Bricht ein Abschnitt ab, nennt der Lauf in **seiner eigenen Ausgabe** den Ausgang — `AUSGANG LEITUNG`, wenn eine ausgehende Anfrage nach einem gepinnten Artefakt **nicht mit 2xx beantwortet** wurde (mit der Zeile, die das trägt), sonst `AUSGANG BAUM`: keine der geführten Formen steht in den gelesenen Zeilen, und der Fehlschlag wird dem **geprüften Baum zugerechnet**. **Der Exit-Code unterscheidet die zwei nicht** und soll es nicht — ein eigener Code lüde dazu ein, den Leitungs-Fall durchzuwinken, und das wäre die Schwellen-Senkung, die [`AGENTS.md`](../AGENTS.md) §3.5 an ein ADR bindet. **Wofür die Unterscheidung gilt, ist ein Kriterium und keine Fundstellen-Liste:** eingeordnet ist **jeder Abschnitt, der ein Bild anfordern kann**. Die Abschnitte sind mechanisch abgegrenzt — jeder führt seinen eigenen Exit-Code (**A** = `grep -cE '\|\| [a-z_0-9]+=\$\?$' harness/tools/full-smoke.sh`). Drei Formen darin fordern nachprüfbar **keines** an: der Trockenlauf (`make -n` führt kein Rezept aus), `make span-clean` (sein Rezept im Ziel ist `rm -rf` plus `echo`) und der Hook-Wrapper (ein Shell-Skript, das das Host-Binär startet und `docker` nicht nennt) — **B** = dieselbe Liste durch `grep -cE ' -n |span-clean|bash "\$wrapper"'`. Der Rest sind make-Stufen und Aufrufe des Werkzeugs (**C** = dieselbe Liste durch `grep -c 'tmpbin/ai-harness-init'`). **Jede** make-Stufe trägt eine Einordnung, dazu die zwei Werkzeug-Aufrufe, die als erste ein noch nicht lokal liegendes Bild anfordern; die Probe darauf ist eine Gleichung statt einer Zählung: **A − B − C** == `grep -cE '^[[:space:]]*einordnen "' harness/tools/full-smoke.sh` **− 2**. **Nicht** eingeordnet sind die übrigen Werkzeug-Aufrufe — sie können nur dieselben zwei Bilder anfordern (das Werkzeug hat genau **einen** Docker-Aufrufpunkt, `printMK` in `internal/emit/emit.go`), und die liegen nach den zwei Erstbezügen lokal; sie laufen unter `set -e` und brechen ohne eigene Meldung ab. Die geführten Formen, ihre Messung und ihre weiteren Grenzen — Paketquellen der C++-Kette sind **keine** gepinnten Artefakte und fallen in den Baum-Fall — stehen im Kopf von `harness/tools/full-smoke-ausgang.sh`; `test/full-smoke-ausgang.bats` fährt beide Richtungen über Ausschnitten echter Läufe. `make span-report` rechnet aus dem Span-Bestand eine **Token-Bilanz je Rolle**. Er steht **bewusst in keiner der Tabellen oben**: ein Bericht prüft nichts und färbt nichts rot, ein Gate über ihm wäre eines über leerem Prüfbereich ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Er liest den Bestand read-only und netzlos; die Ausgabe nennt ihren Nenner, den Sammelposten-Anteil und die Abdeckungszahl samt Bezugsmenge. `make mutate` ist der Mutations-Sensor zu [`AGENTS.md`](../AGENTS.md) §3.6 (slice-026): er wendet ein kuratiertes Set von Mutationen an und meldet jeden Wächter, der dabei **grün** bleibt — die Regel ist sonst nur im Feedforward-Quadranten. **Vor dem Fall-Satz prüft der Lauf einen Beleg** ([`ADR-0035`](../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md), slice-180): War der letzte Lauf über demselben Prüfgegenstand vollständig grün (`fail_count` gleich null), gibt dieser Lauf **diesen Beleg** aus — Exit 0, Beleg-Stand genannt, **keine** Fall-Zahl behauptet — statt den Satz erneut zu fahren. Die **Bezugsmenge** des Schlüssels ist die Isolationskopie aus `prepare_isolation` (`isolation_key_files`), **nicht** der ganze Arbeitsbaum und **nicht** [`harness/tools/working-tree-hash.sh`](../harness/tools/working-tree-hash.sh) — dessen Menge ist für den Gate-Nachweis gepflegt und driftete als zweite Definition desselben Worts gegen diese hier. **Eine deklarierte Ausnahme** zusätzlich zur Kopier-Definition: `.git` (`ISOLATION_KEY_EXEMPT`) — die Kopie braucht es nur für die Projektwurzel (`make ci-lint`/actionlint bricht sonst ab), ein Schlüssel darüber bewegte sich mit jedem Commit ohne Inhaltsänderung. **Benannter Rest**, den kein baum-abgeleiteter Schlüssel deckt: der lokale Docker-Cache-Zustand und die Host-Werkzeuge selbst (bash, tar, git, docker) — `MUTATE_FORCE=1` erzwingt darum den vollen Lauf auch über unverändertem Prüfgegenstand, und die Übersprung-Meldung nennt diesen Rest. **Der Beleg-Slot ist einer, nicht einer je Schlüssel:** ein Lauf über einem anderen Prüfgegenstand entwertet ihn, auch wenn der vorige Schlüssel nie widerlegt wurde — kehrt der Baum zu einem früher grünen Stand zurück, fährt der nächste Lauf trotzdem wieder voll. Fährt der Satz, läuft je Fall **nur der Sensor, dessen Rot erwartet wird** (aus der `# expect:`-Zeile; bei unklarer Erwartung beide Stufen — slice-056). Die Fälle laufen **auf mehrere Worker verteilt** (`MUTATE_JOBS`, Default im Treiber), jeder mit einer **eigenen isolierten Kopie außerhalb des Repos** — nie im Arbeitsbaum; der Lauf misst das selbst — Fingerabdruck der Mutations-Zieldateien vor, **während** und nach dem Lauf, fail-closed (nur diese Dateien, damit paralleles Arbeiten am Repo den Lauf nicht rötet). **Die Worker-Zahl ist eine Zeit-Stellschraube, keine Verdikt-Stellschraube**, und der Lauf belegt das, statt es zuzusagen: jeder Worker fährt den Grün-Vorlauf **der Modi, die er zieht**, in *seiner* Kopie, die Modi, deren Urteil an einem geteilten Docker-Tag hängt, laufen in **einer** Spur, und der zusammengeführte Bericht nennt am Ende, wie viele der Fall-Dateien ein Ergebnis haben und ob jede Fall-Nummer genau einmal gezogen wurde — weicht eines davon ab, ist der Lauf **rot**, nicht kürzer. Am Ende steht die Zeit-Aufschlüsselung je Fall und je Sensor; sie ist eine **Messung**, kein Gate ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) — über ihre eigene Vollständigkeit urteilt sie aber und verweigert eine Bilanz über einer Teilmenge. **Der Lauf begrenzt seine eigene Stille:** vergehen `MUTATE_STALL_SECONDS` (Vorgabe im Treiber, aus der längsten legitimen Stille hergeleitet) ohne dass ein Worker einen Fall zieht oder abschließt, beendet der Lauf **sich selbst**, benennt die noch laufenden Worker und wird rot — ein hängender Sensor ist von einem langsamen sonst nicht zu unterscheiden, und lokal beendet ihn niemand.  **Was sie nicht deckt, steht im Treiber:** beendet wird der **Worker**, nicht dessen Kinder, und ein Hänger im **Vorwärmlauf vor dem Fork** liegt außerhalb — dort gibt es noch keine Worker zu bewachen. Ein Abbruch lässt **im Arbeitsbaum** kein Residuum zurück; außerhalb bleiben ein Temp-Verzeichnis und, nach hartem Kill, das Lock-Verzeichnis liegen — Letzteres bewusst fail-closed. Beide gehören an DoD-Verify/CI/Wellen-Closure, nicht in den offline-schlanken `make gates`.

`make hook-overhead` **misst** den Aufschlag je Tool-Call — die Wanduhr-Zeit **eines** Träger-Aufrufs, nicht die des Tool-Calls, den er beobachtet — und hält ihn gegen die Schwelle aus [`ADR-0011`](../docs/plan/adr/0011-telemetrie-erfassung-policy.md) (*50 ms im Median*); geschuldet ist sie von [`ADR-0022`](../docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Folgepflicht 9. Er steht **in keiner der Tabellen oben und in keiner Prerequisite-Kette**: eine Messung prüft nichts und färbt nichts rot, und ein Latenz-Gate wäre auf einem geteilten Runner rot ohne Befund und grün ohne Deckung ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). `harness/tools/hook-overhead.sh` spielt eine **reale** Folge von Tool-Calls aus dem Span-Bestand nach — Ereignis-Art, Werkzeug-Mischung, Reihenfolge und Ergebnis-Größe je Aufruf stammen aus einem echten Strom, nachgebaut sind Kommando-Text und Ergebnis-Inhalt, die kein Span trägt; ohne Bestand bricht der Lauf ab, statt eine Folge zu erfinden. Der gemessene Stand steht mit seinen Bedingungen und seinen Kommandos im Kopf jenes Skripts, nicht hier: die Zahl gilt dem Host, auf dem sie entstand.

`make slice-mv SLICE=<slice-NNN> TO=<open|next|in-progress|done>` **bewegt** einen Slice-Plan per `git mv` und zieht seine Verweise nach (`AGENTS.md` §3.3, Antwort auf `BEO-ALL/verweise-brechen-beim-ortswechsel`) — **kein Gate, in keiner Prerequisite-Kette**: es bewegt, es prüft nicht ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Voraussetzung ist ein **sauberer Arbeitsbaum** — das Skript committet selbst und bricht sonst vor dem ersten `git mv` ab. Es setzt **zwei getrennte Commits** (Hard Rule 3.3): zuerst der reine Move (kein Byte Inhalt geändert), danach — nur falls Verweise anfielen — der Inhalts-Nachzug als zweiter Commit. Zwei Richtungen: **eingehend** ersetzt jede Präfix-Form eines Verweises **auf** die bewegte Datei, repo-weit außer `.harness/baseline/**` (unveränderter Fremdtext) — `docs/plan/planning/done/**` **und** `docs/reviews/**` sind **nicht** ausgenommen, ihre Verweise sind reale, von `docs-check` geprüfte Links. **Ausgehend** hängt präfixlosen Zielen **innerhalb** der bewegten Datei, die einen im alten Verzeichnis verbliebenen Geschwister-Slice referenzieren, `../<altes-verzeichnis>/` an. Drei gemessene Grenzen (Skriptkopf `harness/tools/slice-mv.sh`): es zieht Pfade nach, keine Zustandssätze; Welle-Plan-Dateien (Tiefenwechsel beim Closure-Move) bleiben außen vor; und eine präfixlose Referenz **auf** die bewegte Datei aus einer *anderen*, unbewegten Datei erkennt es nicht — ihr fehlt das Verzeichnis-Literal, an dem die Ersetzung ankert. `test/slice-mv.bats` deckt die Ersetzungs-Funktionen ohne ein Repo zu bewegen; der Beleg für die Eingehend-Ausnahmeliste selbst braucht ein echtes `git`-Repo (das gepinnte `BATS_IMAGE` führt kein `git`) und steht darum dauerhaft im Skriptkopf (`harness/tools/slice-mv.sh`, Abschnitt BELEG) als Vor/Nach-`docs-check`-Paar an einem echten Move, nicht als bats-Fall.

`make archive-welle WELLE=<welle-id>` **archiviert** die Zeitdokumente einer geschlossenen Welle — Schritt 4 der Wellen-Closure — und ist wie `slice-mv` **kein Gate und in keiner Prerequisite-Kette**: es archiviert, es prüft nicht ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). **Der Träger ist das Produkt-Binär, die Operation sein Unterkommando** ([`ADR-0033`](../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 1); das Target hängt darum an `host-bin` und fährt `.harness/state/bin/ai-harness-init archive-welle "$(WELLE)"` — es gibt genau eine Fassung dieser Operation, und die liegt in `internal/archive`. **Der Unterkommando-Name in dieser Rezept-Zeile ist das zweite Vorkommen desselben Literals**, und zwei Sensoren halten es: `test/unterkommando-kopplung.bats` prüft, dass jeder Name, den ein Aufrufer dieses Repos hinter dem Träger nennt, im Dispatch von `cmd/ai-harness-init/main.go` einen `case` hat — **gelesen bis zum nächsten Wort-Ende** (Zwischenraum, doppeltes Anführungszeichen, Backtick), nicht bis zum ersten Zeichen außerhalb einer Namens-Weißliste: die Menge, aus der der Fall Namen zieht, ist damit echt weiter als die Menge der gültigen, und ein ungültiger erreicht die Prüfung überhaupt erst. **Verglichen wird gegen die Menge der `case`-Marken am Zeilenanfang** — Mitgliedschaft, nicht das Vorkommen der Zeichenkette irgendwo in der Datei: eine Marke in einer Kommentar-Zeile dispatcht nichts, und über dem `switch` steht ein langer Kommentarblock, der den Dispatch beschreibt; `test/mutations/261-dispatch-marke-nur-im-kommentar.sh` nimmt genau dieser Unterscheidung die Zähne, und eine Mehrfach-Marke (`case "a", "b":`) fällt fail-closed aus der Menge statt still hindurch. **Zwei Aufrufer liegen in seinem Prüfbereich**, der `Makefile` und `.claude/settings.json`, dessen Hooks den Träger **direkt** rufen, ohne das Wrapper-Skript, das ein emittiertes Repo bekommt — und der Träger selbst nimmt im Init-Pfad **kein** Positionsargument mehr an, sondern endet mit **Exit 2**, statt ein Repo im Arbeitsverzeichnis anzulegen (`TestInitPfadNimmtKeinPositionsargument` netzlos an `run()`, `TestSubkommandoRouting_UnbekannterNameSchreibtNicht` am Prozess in einem leeren Verzeichnis). **Am Hook-Kanal ist genau dieser Exit 2 der Wert, mit dem ein Hook blockiert:** die Klemme aus [`ADR-0011`](../docs/plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 6 sitzt in `spanEmit()` und deckt, was dort ankommt — ein vertippter Name erreicht `spanEmit()` nie und liegt damit vor ihr; was ihn abfängt, ist der Kopplungs-Fall im Gate (`test/mutations/257-span-emit-hook-name-vertippt.sh` nimmt ihm die Zähne, `test/mutations/258-span-emit-hook-ohne-unterkommando.sh` die Kalibrierung, an der der Träger *ohne* Unterkommando auffällt, und `test/mutations/260-span-emit-hook-name-mit-ziffer.sh` die Wort-Grenze, an der ein Name auffällt, dessen Präfix gültig bleibt — am `Makefile` hält `test/mutations/259-hostbin-name-mit-ziffer.sh` dieselbe Grenze). Warum dafür überhaupt ein Sensor steht: ein falscher **Dateipfad** in dieser Position fällt laut aus, ein falscher **Unterkommando-Name** geht als Zeichenkette durch — der Träger entscheidet erst drinnen, was sie bedeutet. Die Slice-Dateien, der Welle-Plan und die Review-Reports dieser Slices wandern nach `docs/plan/planning/done/<welle-id>/archiv.zip`; an der Stelle von Slice und Plan bleibt je ein gekürzter Stub aus den zwei vendored Vorlagen, die Ergebnisnotiz bleibt vollständig und flach, Review-Reports bekommen keinen. **Eingesammelt wird nach der Welle, nicht nach dem Verzeichnis**, und die Regel liegt im Werkzeug: die Slices, deren `Welle:`-Feld diese Welle nennt, **und** die wellenlosen; wer eine andere Welle nennt, bleibt liegen. Wie `slice-mv` verlangt es einen **sauberen Arbeitsbaum** — gemessen mit `git status --porcelain`, also **einschließlich untrackter Dateien**, weil der Inhalts-Commit der Wave-Self-Close-Punkt ist — und setzt **zwei getrennte Commits** (Hard Rule 3.3): zuerst der reine `git mv` nach `done/<welle-id>/`, danach Archiv, Stubs und Verweis-Nachzug, gestagt über **benannte Pfade** statt über den ganzen Baum. Der Nachzug läuft in **drei** Formen — mit Verzeichnis-Präfix, **geschwister-relativ** (die präfixlose Form, die `slice-mv` als Grenze 3 offenlässt) und **aufsteigend** (`](../<datei>)` in den Dateien unter `done/<welle-x>/`; genau diese Form schreibt das Werkzeug selbst in die Stubs, wenn ein Folge-Slice noch flach in `done/` liegt). **Gepackt wird aus der Go-Standardbibliothek** — kein gepinntes Bild und kein `zip`-Binär; kein Eintrag trägt einen Zeitstempel aus der Uhr des Laufs, also liefern zwei Läufe über demselben Inhalt dieselben Bytes ([`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), gemessen von `TestZipIstUeberZweiLaeufeByteGleich`). **Jeder Ausgang ist fail-closed**, nicht kulant: am ruhenden Baum sind es acht Sperren (`grep -c 'Kennung: "' internal/archive/vorschau.go`, kein Erwartungswert), und der Lauf bricht an jeder von ihnen ab, **bevor** er etwas anfasst — dieselbe Vorprüfung, die `--vorschau` ausgibt. Ein wellenloser Bestand ohne beobachtbare Untergrenze (kein `done/*/archiv.zip`) bricht ab, statt den Altbestand mitzunehmen; ein Review-Report, auf den noch verwiesen wird, bricht ab, statt einen nach [`AGENTS.md`](../AGENTS.md) §3.4 eingefrorenen Verweis zu brechen; dazu „schon archiviert", „unsauberer Baum", fehlende Ergebnisnotiz, fehlender und mehrdeutiger Welle-Plan sowie „kein Slice eingesammelt". Zwei Ausgänge stehen daneben, weil sie am ruhenden Baum nicht beobachtbar sind: das fehlende `WELLE=` fängt der Aufrufer vorher ab, und eine **verletzte Stub-Form** bricht **zwischen** den zwei Commits ab und nennt den Rückweg (`git reset --hard HEAD~1 && git clean -fd`). **Der Suchraum der Verweis-Vorprüfung nimmt allein `.git` und `.harness/baseline/**` aus** — `docs/reviews/**` steht darin, denn `links`/`anchors` prüfen die Zeitdokumente wie jede andere Datei, und Reports verlinken einander quer über Wellen-Grenzen.

**Was am Werkzeug gedeckt ist und was nicht.** `make test` fährt die Einsammel-Regel samt Suffix-Grenze, die Stub-Erzeugung aus der Vorlage, alle drei Ersetzungsrichtungen, die Zwei-Commit-Trennung und die gestagte Pfad-Liste über synthetischen Bäumen — die vier git-Operationen kommen dabei als Schnittstelle herein, und kein Fall dieser Gruppe bewegt ein Repo. **Daneben steht ein Lauf gegen ein echtes Repo** (`cmd/ai-harness-init/archive_welle_echt_test.go`): der Träger startet als Prozess in einem Scratch-Repo, und die Verdrahtung `echterEingang()` trägt ihn — die zwei fail-closed-Sperren, die aus der Außenwelt entstehen, fallen dort je einzeln, und ein dritter Fall führt die Operation zu Ende (zwei Commits, sauberer Arbeitsbaum danach). **Einzeln gemessen ist von den vier schreibenden git-Aufrufen der erste** — `Mv` als No-Op lässt Commit 1 über einen leeren Index laufen; für `Rm`, `Add` und `Commit` trägt der Fall nur ihr Zusammenspiel. Und weil `.dockerignore` den vendored Baum aus dem Build-Kontext der Go-Test-Stufe hält, fahren die Go-Tests über *synthetischen* Vorlagen; die Kopplung an die **echten** hält `test/archiv-stub-vorlagen.bats` — **je Vorlage einzeln**: jeder Platzhalter steht in genau der Vorlage, die *sein* Block füllt (`sliceStub` → Slice-Vorlage, `welleStub` → Welle-Vorlage), die Zuordnung kommt aus den Konstanten des Codes, und ein zweiter Fall hält die Extraktion beider Blöcke gegen ihre eigene Bezugsmenge — ohne ihn wäre ein ins Leere laufender Bereich eine Quantifizierung über die leere Menge und damit still grün. Eine Frage über der **Vereinigung** beider Vorlagen bliebe grün, wenn ein Platzhalter, den beide tragen, in genau einer umbenannt würde. **Vier Grenzen bleiben gemessen bestehen:** der Nachzug hängt **Pfade** um, keine Zustandssätze (ein Satz „liegt in `done/`" wird richtig verlinkt und bleibt ungenau); ein eingehender Verweis in **Inline-Code ohne Verzeichnis-Segment** trägt keine Link-Klammer und wird nicht getroffen — `make docs-check` nach dem Lauf zeigt den Rest; das Feld `Geschlossen:` nimmt das Datum aus der `**Rolle:** … **Datum:**`-Zeile der Closure-Notiz und sonst das Abschluss-Datum der Welle; und ein Review-Report über **mehrere** Slices trägt die Plural-Form im Namen („…-slices-011-014-…"), fällt damit durch die Einsammel-Regel und bleibt flach liegen.

**Auf eine Welle dieses Repos ist das Werkzeug noch nicht anwendbar**, und das ist eine Messung, keine Vorsicht: über einem Klon des Hauptzweigs steht die Sperre `untergrenze` und die Sperre `haenger`. Der Altbestand hat keine Untergrenze (es gibt noch kein `done/*/archiv.zip`), und die Review-Reports der einzusammelnden Slices tragen lebende Verweise aus [`spec/lastenheft.md`](../spec/lastenheft.md), aus `docs/plan/carveouts/done/`, aus nach [`AGENTS.md`](../AGENTS.md) §3.4 eingefrorenen ADRs **und aus anderen Review-Reports**, die einander quer über Wellen-Grenzen verlinken — 83 Report-Dateien sind Ziel eines solchen Links (`for r in docs/reviews/*.md; do rb="${r##*/}"; grep -rlF -e "]($rb)" docs/reviews/ | grep -vxF "$r" | sed "s|.*|$rb|"; done | sort -u | wc -l`, kein Erwartungswert). Beides sind eigene Vorgänge, die vor der ersten Archivierung liegen — das Werkzeug benennt sie in seiner Abbruch-Meldung, statt sie zu überspringen.

`ai-harness-init archive-welle --vorschau <welle-id>` **sagt**, was derselbe Lauf täte, und schreibt dabei nichts: der Schalter hält den Aufruf nach der Vorprüfung an. Erreicht wird er über den **Träger**, den `make host-bin` in den gitignorierten Zustands-Bereich legt — `.harness/state/bin/ai-harness-init archive-welle --vorschau <welle-id>`; ein eigenes `make`-Ziel hat er nicht. Er ist keine zweite Fassung der Operation, sondern **derselbe Code**: die Vorschau ist die Vorprüfung des schreibenden Laufs, und was sie an Sperren nennt, sind genau die Ausgänge, an denen er abbricht. Gemessen ist er an einem **sperrenfreien** Baum — nur dort sagt eine Messung etwas, denn steht eine Sperre, endet schon die Vorprüfung. Über diesem Baum stehen **zwei** Aussagen, und sie sind nicht dieselbe: der **Parameter** `vorschau` hält den Zweig an (`TestArchiveWelleVorschauSchreibtNichtsObwohlDerLaufLiefe` prüft Exit-Code, git-Aufrufe und einen Abdruck des ganzen Baums, `TestArchiveWelleSchreibendLaeuftAmSelbenBaum` ist die Gegenprobe ohne ihn) — und die **Strecke vom Argument bis dorthin** trägt: `TestArchiveWelleReichtDenSchalterVomArgumentBisZumZweig` gibt `--vorschau` als *Argument* ins Feld und misst denselben Abdruck, `TestArchiveWelleOhneSchalterSchreibtAmSelbenArgumentFeld` ist deren Gegenprobe, und `TestParseArchiveWelleGewinntDenSchalterAusDemArgument` hält die Parser-Hälfte in beiden Argument-Reihenfolgen und ohne den Schalter. **Die Verdrahtung `echterEingang()` daneben** — sie schiebt dem Betriebs-Aufruf die echte Repo-Wurzel, die zwei lesenden git-Aufrufe und die vier schreibenden unter — ist **Feld für Feld gegen ein echtes Repo gemessen**, in `cmd/ai-harness-init/archive_welle_echt_test.go`: `TestArchiveWelleEchtSperrtAmUnsauberenArbeitsbaum` läuft aus einem Unterverzeichnis heraus und hängt damit an `wurzel` und an `porcelain`, `TestArchiveWelleEchtSperrtAmHaengendenVerweis` an `dateien`, `TestArchiveWelleEchtArchiviertUndSetztZweiCommits` an `schreibend`. Der Compiler trägt daran nur eine Hälfte: die vier Signaturen sind paarweise verschieden, eine Vertauschung untereinander übersetzt nicht — dass in jedem Feld die *echte* Fassung steht, ist eine andere Frage, und eine Fassung, die `git` weiter startet und seine Antwort verwirft, übersetzt sehr wohl.

Ausgegeben werden — von **beiden** Zweigen, denn es ist dieselbe Vorprüfung — die **vier Einsammel-Zahlen** (Mitglieder · wellenlos · fremd · Review-Reports), der **Blast-Radius** — jede Datei mit einem Verweis auf etwas Bewegtes, aufgeschlüsselt nach den drei Formen — und die **Sperren**. Die Verweis-Zeile trägt **zwei Einheiten, beide beschriftet**: die erste Zahl zählt Dateien, die drei in der Klammer Fundstellen über alle Dateien; letztere können die erste übersteigen. Der Exit-Code trägt dasselbe Urteil noch einmal: **0** Lauf bzw. Vorschau gefahren, keine Sperre, **3** mindestens eine Sperre — geschrieben wurde nichts, **2** Aufruf-Fehler, **1** Laufzeit-Fehler. Er ist damit **kein Gate und in keiner Prerequisite-Kette**: geprüft werden die Vorbedingungen *einer Operation*, nicht der Zustand des Repos ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

**Beide Zweige durchsuchen denselben Raum, an beiden Achsen — es ist dieselbe Funktion.** Durchsucht wird, was `git ls-files` führt — jede getrackte Datei, ohne Dateityp-Einschränkung, ausgenommen allein `.git` und `.harness/baseline/**` (dieselbe Menge wie oben, sie steht im Code an einer Stelle); `docs/reviews/**` steht darin. Beide Achsen tragen: Verweise auf ein verschwindendes Zeitdokument stehen im Bestand auch in Shell-Hooks und -Helfern, in Go-Kommentaren, in Mutations-Fällen und in bats-Dateien (`for r in docs/reviews/*.md; do git grep -lF -e "${r##*/}" -- ':!.harness/baseline' ':!*.md'; done | sort -u`, kein Erwartungswert — die vier Klassen decken die Ausgabe vollständig ab). Nur die zwei **relativen** Verweis-Formen sind zusätzlich auf `.md` begrenzt — sie sind Markdown-Link-Ziele und lösen außerhalb einer Markdown-Datei gegen nichts auf —, und die geschwister-relative zählt nicht in den Dateien, die dieser Lauf selbst mitzöge.

Die Urteils-Logik liegt in `internal/archive/` und ist über synthetischen Bäumen geprüft (`make test`); `git` läuft in genau **einer Datei** (`cmd/ai-harness-init/archive_welle.go`) — zwei lesende Aufrufe (`git status --porcelain`, `git ls-files -z`), deren Ergebnisse als Werte in die Logik gehen, und vier schreibende hinter einer Schnittstelle, die der Test selbst verdrahtet; deshalb braucht die Prüfung der Urteils-Logik kein Repo. **Die Verdrahtung dieser sechs Aufrufe in den Lauf braucht eines** und bekommt es in `cmd/ai-harness-init/archive_welle_echt_test.go` — ein Scratch-Repo je Fall, der Träger als Prozess darin. Bewacht sind mit je einem Fall unter `test/mutations/`: die drei Einsammel-Klassen · alle **vier** Abnahme-Kriterien-Hälften aus [`ADR-0033`](../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) (untrackter Bestand · `docs/reviews/**` im Hänger-Suchraum · explizites Staging · aufsteigender Verweis beim Folgelauf) · die Dateityp-Achse des Suchraums · der `main()`-Dispatch-Zweig, dessen Durchfall in den **schreibenden** Init-Pfad führt · die Sperre eine Stufe davor, die im Init-Pfad **jedes** Positionsargument als Aufruf-Fehler nimmt (ein Name, für den es nie einen `case` gab, hat keinen Zweig, der umgehängt werden könnte) · die Kopplung der zwei Nennungen des Literals, `Makefile`-Rezept gegen Dispatch · die **leere** Kennung, die das Rezept ohne gesetztes `WELLE=` weiterreicht (sie ist ein Argument, kein leeres Argument-Feld, und nur die Prüfung nach der Parser-Schleife trennt beides) · die Stub-Form und, davon getrennt, ihre **Verdrahtung** in den Lauf · die Zwei-Commit-Trennung · der **Vorschau-Schalter** auf allen **drei** Stufen seiner Strecke, je mit eigenem Fall (der Parser gewinnt den Wert · der Wert erreicht den Zweig · der Zweig hält an) · die Platzhalter-Kopplung an die vendored Vorlagen in **zwei** Richtungen (die Extraktion sieht jede Literal-Form · die Frage geht je Vorlage einzeln) · **drei der vier Felder der Betriebs-Verdrahtung**, je einzeln (die Wurzel steigt nicht auf · die `porcelain`-Antwort wird verworfen · der Suchraum bleibt leer) · und der erste der vier schreibenden git-Aufrufe (`Mv` bewegt nichts). Wie viele Fälle das sind, sagt `ls test/mutations/*archive-welle*.sh test/mutations/*archiv-stub-vorlage*.sh | wc -l` (kein Erwartungswert, [`MR-025`](conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

`make vendor-baseline` legt den vendored Baum **dieses** Repos (`.harness/baseline/$(BASELINE_TAG)/`) aus dem verifizierten Release-Asset an, statt ihn von Hand aus einem fremden Arbeitsbaum zu kopieren — wie `slice-mv` und `archive-welle` **kein Gate und in keiner Prerequisite-Kette**: es stellt her, es prüft nicht ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)); der Beleg ist `make baseline-verify` nach demselben Lauf. Die Fähigkeit liegt vollständig in `internal/fetch.Baseline` ([`LH-FA-09`](../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)) und hat außerhalb der Tests **zwei** Aufrufer: den Init-Pfad für Zielrepos und dieses Ziel, für den eigenen Baum. **KONVERGENT** ([`ADR-0007`](../docs/plan/adr/0007-bootstrap-phasen.md)): ein vorhandenes `<tag>`-Verzeichnis, das genau dem übergebenen Tag entspricht, wird ersetzt, kein zweites legt sich daneben ([`MR-007`](conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 4). Liegt statt dessen ein **anderer** Tag da (ein Tag-Bump), bricht der Lauf **vor** jedem Zugriff ab, statt das zweite Verzeichnis zu erzeugen — dieses Ziel vendort nur den übergebenen Tag neu, einen Tag-Wechsel zieht es nicht nach (`TestVendorBaselineMit_AndererTagBrichtAbOhneSchreibzugriff`, `cmd/ai-harness-init/vendor_baseline_test.go`). Tag und sha256 kommen als Argumente aus den kanonischen Makefile-Variablen `BASELINE_TAG`/`BASELINE_ZIP_SHA256` — kein zweiter, eingebetteter Wert; weicht der aus dem Asset berechnete sha256 ab, bricht der Lauf **vor** jedem Schreibzugriff ab (`internal/fetch.SHA256Mismatch`), ein bestehender Baum bleibt unverändert.

Der Anlass ist gemessen, nicht vermutet: Der committet-vendored Baum kam beim Sprung auf `v6.5.0` zunächst aus dem `git`-Baum des Kurs-Klons statt aus dem Asset — die zwei Quellen unterschieden sich in **28 Dateien** (`git diff --name-only 962c1722^ 962c1722 -- .harness/baseline/v6.5.0 | grep -v SHA256SUMS | wc -l`; die Zahl ist an die zwei Tree-Operanden des Tausch-Commits gebunden und darum fest, die derivative `SHA256SUMS` ist ausgenommen — sie zeichnet jede Content-Änderung nur nach, statt selbst eine Quelle zu sein), das Symptom ist behoben, der fehlende Träger war die Ursache. Real gemessen gegen den heute gepinnten Tag: der Lauf reproduziert den committeten Baum byte-gleich (`git status --porcelain -- .harness/baseline/` bleibt leer), `make baseline-verify` meldet danach `OK`, und ein Lauf mit falschem sha256 bricht mit Exit 1 ab, ohne den Baum anzufassen. Dasselbe Gegenbeispiel hält netzlos `TestVendorBaselineMit_SHA256MismatchNichtsVeraendert` (`cmd/ai-harness-init/vendor_baseline_test.go`, `make test`); die Verdrahtung selbst — Parser und Usage, Repo-Wurzel-Auflösung, das Ersetzen eines vorhandenen `<tag>`-Verzeichnisses samt dem Abbruch bei einem anderen, der sha256-Abgleich und der `main()`-Dispatch-Zweig — deckt dieselbe Datei in **9** Fällen (`grep -c '^func Test' cmd/ai-harness-init/vendor_baseline_test.go`, kein Erwartungswert).

## Traceability

- PRs/Commits nennen mindestens eine `LH-*`- oder `ADR-*`-ID (als Link oder Inline-Code).
- Neue ADRs ergänzen den ADR-Index.

## Minimal agent workflow

1. Diese Datei lesen.
2. Relevante kanonische Quelle lesen (Source Precedence).
3. Betroffene IDs identifizieren.
4. Kleinste sinnvolle Änderung planen.
5. Engsten nützlichen Sensor laufen lassen.
6. Repo-weiten Gate-Lauf vor Handoff (`make gates`).

## Leseordnung

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-harness-dateien.md`
§harness/README.md als Einstiegspunkt — die Menschen-Hälfte des Einstiegs:
drei bis fünf **geordnete** Zeiger, was ein neuer Mensch zuerst liest und was
bei Bedarf; eine Leseordnung, die alles nennt, ist keine.

1. [`AGENTS.md`](../AGENTS.md) §3 — die Hard Rules, vor jedem Lauf.
2. [`spec/lastenheft.md`](../spec/lastenheft.md) — was dieses Repo vertraglich
   liefert.
3. [`docs/plan/planning/in-progress/roadmap.md`](../docs/plan/planning/in-progress/roadmap.md)
   — woran gerade gearbeitet wird.
4. [`conventions.md`](conventions.md) — bei Bedarf: der Index der Adaptionen von der
   Baseline (der Eintrag selbst liegt unter [`conventions/`](conventions/)), Modus-Deklaration.

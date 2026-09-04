# Review Runde 2 — slice-175, Nachprüfung der Behebungen am schreibenden Pfad von `archive-welle`

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Implementation, Architektur und Planung |
| **Review-Art** | Nachprüfung der Behebungen aus Runde 1, plus Diff gegen Plan und Hard Rules. **Nicht** DoD-Abhakung und **keine** Gate-Lauf-Bestätigung (Verifier, Modul 11) |
| **Gegenstand** | `git diff ef18c90..07d5bbb` — drei Behebungs-Commits `089f0df` (HIGH-1, MEDIUM-1, INFO-1: drei neue Zähne, `test/mutations/242`, `243`, `245`), `ff83157` (MEDIUM-2: Extraktion des Vorlagen-Wächters neu gefasst, `test/mutations/244`), `07d5bbb` (LOW-1, LOW-2, INFO-2: vier Aussagen nachgezogen) |
| **Runde 1** | [`2026-09-04-slice-175-schreibender-pfad-review.md`](2026-09-04-slice-175-schreibender-pfad-review.md) — 1 HIGH, 5 MEDIUM, 2 LOW, 2 INFO |
| **Plan** | [`docs/plan/planning/in-progress/slice-175-archive-welle-schreibender-pfad.md`](../plan/planning/in-progress/slice-175-archive-welle-schreibender-pfad.md) |
| **Bindende ADRs** | [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) (**`Proposed`**, Prüfmaßstab laut Plan), [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (**`Accepted`**), [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md), [ADR-0003](../plan/adr/0003-go-native-binaries.md) |
| **Anforderungen** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit); [`AGENTS.md`](../../AGENTS.md) §3.2, §3.3, §3.6, §3.7, §3.9; [`MR-009`](../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile), [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.6.0 |
| **Modell** | Claude Opus 5 (1M context) |
| **Kontext frisch** | ja — **kein Beleg aus dem Implementer-Bericht und keiner aus dem eigenen Runde-1-Report übernommen.** Jede Aussage über ein Rot oder ein Grün unten ist in dieser Sitzung selbst gemessen; das Kommando steht beim Befund |

**Wie gemessen wurde.** Zehn Sonden in einer **Kopie des Baums außerhalb des Repos**
(`tar --exclude=.git --exclude=.harness/state`, Scratch-Verzeichnis) plus zwei
End-to-End-Läufe eines dort gebauten Trägers gegen synthetische git-Repos. Der Arbeitsbaum
dieses Repos wurde zu keinem Zeitpunkt verändert (`git status --porcelain` vor und nach den
Sonden leer). Alle Läufe Docker-only über `make` ([`AGENTS.md`](../../AGENTS.md) §3.9).

**Eine Vorbemerkung zur Kopie, damit kein Rot falsch gelesen wird:** `make test-bats` meldet in
der Kopie durchgehend genau einen Ausfall — `not ok 127 driver: die Kopie traegt den
Sensor-Bedarf inklusive .git` —, und zwar **auch ohne jede Mutation** (gemessen am
unmutierten Stand). Er ist Artefakt des fehlenden `.git` in der Kopie und in keiner Sonde
unten ein Signal.

---

## Findings

### HIGH-1 — Gemessen wird der Parameter `vorschau`, zugesagt ist „der Schalter selbst"; die Strecke vom Flag zum Guard ist unbewacht

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (Hard Rule — *„Ein Test, dessen Name eine
  Eigenschaft behauptet, muss die Eigenschaft messen, nicht ihre heutige Implementierung"*) ·
  [`AGENTS.md`](../../AGENTS.md) §3.7 (Klasse *Zusage*) ·
  [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) §Konsequenzen
- **pfad:** `cmd/ai-harness-init/archive_welle.go:155-156` (die ungewächtete Stelle) ·
  `cmd/ai-harness-init/archive_welle_test.go:78` (der Test übergibt `true` als Literal) ·
  `cmd/ai-harness-init/archive_welle.go:13-16` und
  [`harness/README.md`](../../harness/README.md) Zeile 85 und 91 (die Zusagen) ·
  `test/mutations/242-archive-welle-go-vorschau-schaltet-nicht-ab.sh:6`
- **befund:** Der neue Zahn misst `archiveWelleLauf(root, "welle-10", **true**, …)` — den
  **Parameter**. Die einzige Stelle, die diesen Parameter aus dem Kommandozeilen-Schalter
  gewinnt, ist `case a == "--vorschau": vorschau = true` in `parseArchiveWelle`, und sie steht in
  keinem Test: kein Fall ruft `archiveWelle` mit einer gültigen `<welle-id>` **und**
  `--vorschau` (`grep -rn -- "--vorschau" test/` nennt genau eine Datei, den Mutations-Fall
  242; die vier Fälle in `archive_welle_test.go:216-218` enden alle vor der Verzweigung mit
  Exit 2). Gemessen in dieser Sitzung, Mutation `vorschau = true` → `vorschau = false` in
  Zeile 156, sonst nichts: `make test-go` **grün** (alle acht Pakete `ok`), `make lint`
  **grün** (*0 issues*), `make test-bats` unverändert. Der aus derselben Kopie gebaute Träger
  (`make host-bin`) druckt dann gegen ein sperrenfreies Repo erst
  *„Sperren: keine — der schreibende Lauf liefe."* und archiviert unmittelbar danach:
  `rev-list --count HEAD` **1 → 3**, `git log --oneline` zeigt
  *„archive-welle: welle-10  Zeitdokumente nach … (reiner Move)"* und
  *„… Archiv, Stubs und Verweis-Nachzug (Inhalt …)"*, Slice-Datei und Welle-Plan durch Stubs
  ersetzt, `archiv.zip` (518 Bytes) angelegt, **Exit 0**. Die drei Zusagen daneben sprechen
  dagegen vom **Schalter**: `harness/README.md:85` *„Dass **der Schalter selbst** hält, ist an
  einem sperrenfreien Baum gemessen"*, `:91` führt *„der **Vorschau-Schalter**"* in der Liste
  der bewachten Dinge, und der Kopf von 242 sagt *„NIMMT DEM VORSCHAU-SCHALTER SEINE
  WIRKUNG"*, während sein `sed` `if vorschau {` trifft. Das ist die schärfste Form von
  `BEO-025`: eine Zusage nennt einen Sensor, und der Sensor sieht genau diese Form nicht.
- **verifizierbar:** ja — `make test-go`, `make lint` und `make test-bats` nach
  `sed -i 's/^\t\t\tvorschau = true$/\t\t\tvorschau = false/' cmd/ai-harness-init/archive_welle.go`;
  heute alle drei grün, erwartet rot.
- **klasse:** Zahn misst den Parameter, die Zusage nennt den Schalter — die Verdrahtung
  dazwischen ist unbewacht (`BEO-025`, Sensor-Variante)

### MEDIUM-1 — Der Platzhalter-Wächter prüft gegen die **Vereinigung** beider Vorlagen; eine Umbenennung in genau einer bleibt grün

- **kategorie:** MEDIUM
- **quelle:** [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 3 ·
  [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `test/archiv-stub-vorlagen.bats:93-110` (der Fall) und `:8-14` (die Zusage im
  Datei-Kopf)
- **befund:** Der Fall prüft je Platzhalter *„steht in **einer** der zwei Vorlagen"* — ein
  `grep -qF` gegen die Slice-Vorlage **oder** die Welle-Vorlage. **Fünf** von zehn aufgelösten
  Platzhaltern stehen in **beiden** Vorlagen, fünf in genau einer (Zähl-Schleife über die
  Extraktion aus `test/archiv-stub-vorlagen.bats` gegen beide Vorlagen; keine Erwartungswerte,
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2). Für die fünf in beiden genügt ein Treffer in der anderen Datei.
  Gemessen in dieser Sitzung: nach
  `sed -i 's|done/<welle-id>/archiv\.zip|abgelegt/<welle-id>/archiv.zip|' .harness/baseline/v5.18.0/templates/docs/plan/planning/archiv-stub-welle.template.md`
  bleiben alle vier bats-Fälle grün (`ok 17` bis `ok 20`), weil die Slice-Vorlage die Zeichenkette
  weiter trägt. Der **unveränderte** Träger schreibt gegen ein Repo mit derselben Änderung
  einen Welle-Stub, dessen Archiv-Zeiger
  `unzip -p abgelegt/welle-10/archiv.zip docs/plan/planning/done/welle-10/welle-10-eine-welle.md`
  lautet — ein Pfad, den es nicht gibt —, während der Slice-Stub daneben korrekt ist; Exit 0.
  `FormOK` fängt das nicht: sie prüft `strings.Contains(inhalt, archivName)`
  (`internal/archive/stub.go:130`), und `archiv.zip` steht weiter darin. Der Datei-Kopf sagt
  dagegen, ohne diese Datei käme eine Form-Änderung der Baseline *„erst beim nächsten
  Archivierungslauf ans Licht — als Stub mit einem stehengebliebenen Platzhalter"*, und
  benennt als Grenze ausdrücklich nur die **andere** Richtung (Vorlage → Code). Der Zeiger ist
  das Einzige, was nach der Archivierung vom Volltext übrig bleibt.
- **verifizierbar:** ja — die obige `sed`-Umbenennung, dann
  `docker run … $(BATS_IMAGE) test/archiv-stub-vorlagen.bats`; heute grün, erwartet rot.
- **klasse:** Wächter quantifiziert über die Vereinigung, die Zusage über jede einzelne Datei
  (`BEO-025`)

---

## Negativbefunde — geprüft, ohne Befund

**Die drei Behebungen, die Runde 1 blockierend gemacht hat — alle drei mit genau der Mutation
nachgemessen, die dort grün blieb:**

- **HIGH-1 aus Runde 1 ist geschlossen.** `sed -i '107,109d' cmd/ai-harness-init/archive_welle.go`
  — der Guard `if vorschau { return 0 }` **vollständig entfernt**, nicht nur die gelistete
  `if false`-Form — färbt `make test-go` rot:
  `--- FAIL: TestArchiveWelleVorschauSchreibtNichtsObwohlDerLaufLiefe`, Paket
  `cmd/ai-harness-init` `FAIL`. Der neue Fall stellt den sperrenfreien Baum wirklich her
  (`sperrenfreierBaum` legt Ergebnisnotiz, genau einen Welle-Plan, einen Mitglieds-Slice und
  beide Stub-Vorlagen an), prüft die Vorbedingung *„Sperren: keine"* als einziges `Fatal`
  vorweg und misst danach drei unabhängige Wege — Baum-Abdruck über Pfad, Länge und
  SHA-256 **einschließlich Verzeichnissen**, git-Aufrufe, Exit-Code. Die Gegenprobe
  `TestArchiveWelleSchreibendLaeuftAmSelbenBaum` fährt denselben Baum ohne den Parameter und
  fällt, wenn dort **nichts** passiert — damit kann der Fall oben nicht durch einen
  wirkungslosen Baum grün werden. Kein Befund an dieser Stelle; was offen bleibt, ist die
  Strecke davor (HIGH-1 dieser Runde).
- **MEDIUM-1 aus Runde 1 ist geschlossen.** `sed -i '230,232d' internal/archive/anwenden.go` —
  der `FormOK`-Aufruf samt Rückgabe entfernt — färbt `make test-go` rot:
  `--- FAIL: TestAnwendenBrichtBeiVerletzterStubFormAb`, Paket `internal/archive` `FAIL`. Der
  Fall misst die Verdrahtung statt der Logik: er prüft nach dem Abbruch, dass die bewegte
  Datei noch ihren **Volltext** trägt, also dass das Form-Urteil **vor** dem Schreibzugriff
  fällt. Kein Befund.
- **MEDIUM-2 aus Runde 1 ist in der gemessenen Richtung geschlossen.** Die Umbenennung
  `<welle-id>-results.md` → `<welle-id>-ergebnisse.md` in der vendored Welle-Vorlage — der
  Fall, der in Runde 1 grün blieb — färbt jetzt `not ok 19 jeder Platzhalter der
  Stub-Erzeugung steht in einer der zwei Vorlagen`. Die Extraktion löst den **ersten Ausdruck**
  jedes Ersetzungs-Literals auf statt an einem Schluss-Zeichen zu erkennen, sie löst die
  zusammengesetzte Form über die Konstante in `collect.go` auf, und sie **fällt** bei einer
  unbekannten Form statt sie zu überspringen; der zweite Fall (`ok 18`) hält die Deckung
  *aufgelöst == Anzahl der Literale*. Kein Befund in dieser Richtung; die verbliebene Lücke
  ist MEDIUM-1 dieser Runde und liegt in der Quantifizierung über die zwei Dateien, nicht in
  der Extraktion.

**Die vier neuen Mutations-Fälle:**

- **Jeder `# expect:`-Name löst auf.** `TestArchiveWelleVorschauSchreibtNichtsObwohlDerLaufLiefe`,
  `TestAnwendenBrichtBeiVerletzterStubFormAb` und `TestAnwendenTrenntMoveVonInhalt` existieren
  je einmal als Go-Testfunktion (`git grep -c "func <Name>(" -- '*_test.go'` → je **1**); der
  `# expect:`-Text von 244 existiert einmal als bats-Fall
  (`grep -c '@test "jeder Platzhalter der Stub-Erzeugung steht in einer der zwei Vorlagen"' test/archiv-stub-vorlagen.bats`
  → **1**). Kein Erwartungswert ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2). Kein Befund.
- **Jedes `sed`-Muster trifft genau einmal.** 242 (`grep -cP '^\tif vorschau \{$' cmd/ai-harness-init/archive_welle.go`),
  243 (`grep -cP '^\t\tif err := FormOK\(text\); err != nil \{$' internal/archive/anwenden.go`)
  und 245 (`grep -cF 'if err := g.Commit("archive-welle: " + b.Welle + …' internal/archive/anwenden.go`)
  → je **1**; keine Erwartungswerte. Ein Fall, dessen Muster ins Leere liefe, wäre ein
  Gegenbeispiel, das nie rot wird — die Klasse `BEO-028`. Kein Befund.
- **244 benennt seine Baseline-Kopplung selbst.** Der `# files:`-Kopf trägt den Tag
  `v5.18.0`; der Fall sagt im Kopf, dass er nach einem Bump unter `set -euo pipefail` fällt und
  die Vollständigkeits-Schranke des Treibers daraus einen Befund macht — laut statt still.
  Kein Befund.

**Die drei nachgezogenen Aussagen aus `07d5bbb`:**

- **LOW-1 aus Runde 1 ist geschlossen.** [`harness/README.md`](../../harness/README.md) nennt
  die Suchraum-Ausnahme an beiden Stellen gleich (`.git` **und** `.harness/baseline/**`) und
  sagt daneben, dass es dieselbe Menge ist und wo sie im Code steht. Der Aufruf-Bestand ist
  vollständig (zwei lesende, vier schreibende hinter einer Schnittstelle) statt nur der zwei
  lesenden. Kein Befund.
- **LOW-2 aus Runde 1 ist geschlossen, und die Wiedergabe stimmt mit der Quelle.**
  `.d-check.yml` sagt jetzt *„MR-009 ist PERMANENT; seine Wachstums-Klausel ist eine Bedingung
  an diese Liste, kein Aufloesungs-Trigger"*; `MR-009` §Auflösungs-Trigger lautet
  *„permanent; … `ignore-refs` wächst nur mit weiteren **bewusst entfernten** Artefakten"*
  (`grep -n "Auflösungs-Trigger" harness/conventions/MR-009-d-check-pin-sprung-und-codepath-ventile.md`
  → eine Zeile). Kein Befund.
- **INFO-2 aus Runde 1 ist als Kopplung benannt.** Der Makefile-Kommentar über
  `archive-welle: host-bin` nennt jetzt `.gitignore` als Voraussetzung, das Kommando, das die
  Zeile ausgibt, und die Folge einer Verengung. Er beschreibt die Stelle im Indikativ und
  trägt die Klasse *Kopplung* ([`AGENTS.md`](../../AGENTS.md) §3.7). Kein Befund.
- **INFO-1 aus Runde 1 hat seinen Fall.** `test/mutations/245` nimmt dem Lauf den
  Move-Commit; `TestAnwendenTrenntMoveVonInhalt` ist sein benannter Wächter, und das Muster
  trifft. Kein Befund.

**Was der Behebungs-Diff sonst berührt:**

- **Lint-Suppression-Verbot** ([`AGENTS.md`](../../AGENTS.md) §3.2). Die drei Commits führen
  kein `//nolint`, kein `# shellcheck disable` und kein `d-check:ignore` ein
  (`git diff ef18c90..07d5bbb | grep -nE '^\+.*(nolint|shellcheck disable|d-check:ignore)'`
  leer). Kein Befund.
- **Docker-only** ([`AGENTS.md`](../../AGENTS.md) §3.9). Kein neuer Host-Aufruf; die neuen
  Go-Tests laufen über `t.TempDir()` und die Attrappe `gitStumm`, ohne ein Repo und ohne
  `git`. Kein Befund.
- **Kein Artefakt einer fremden Rolle angefasst** ([`AGENTS.md`](../../AGENTS.md) §3.8,
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)). Die drei
  Commits berühren `AGENTS.md`, `harness/conventions*`, `docs/plan/adr/`,
  `docs/plan/planning/` und `.claude/commands/` nicht
  (`git log --oneline 1f2a8a8..HEAD -- docs/plan/planning/ .claude/commands/close-welle.md`
  leer). Kein Befund.

**Die drei delegierten MEDIUM aus Runde 1 — die Abgrenzung stimmt, geprüft statt übernommen:**

- **MEDIUM-5 (`.claude/commands/close-welle.md`) gehört dem Planner.**
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) trägt
  **`Accepted`** (Zeile 3) und führt die Datei namentlich mit dem Träger **Planner**, belegt
  über deren eigenen Eröffnungssatz (*„Dieser Command führt die **Planner**-Rolle für die
  **Wellen-Closure**"*). Dass die Implementation die Datei nicht angefasst hat, ist damit
  korrekt und nicht Nachlässigkeit.
- **MEDIUM-3 (Zähler-Stand in §6/§8 des Slice-Plans) gehört dem Planner.** Der
  Sichtungs-Schritt ist Planungs-Leistung (`modul-05-planning-harness.md` §Zwei Schritte vor
  der Modus-Begründung), und Modul 8 §Rollen-Sequenz für eine Welle führt den Lese-Schritt im
  Planner-Kontext. Der Befund steht unverändert offen: Plan Zeile 160/220 sagt `BEO-009` **8×**
  und Zeile 167/221 `BEO-025` **1×**, das Register sagt **9×** bzw. **2×**
  (`awk -F'|' '/BEO-0(09|25)/ {print $2, $5}' docs/plan/planning/observations.md`). Keine
  Erwartungswerte.
- **MEDIUM-4 (`Stand`-Zellen im Beobachtungs-Register) gehört dem Planner.** Eingetragen wird
  bei der Slice-Closure (`modul-06-roadmap.md` §Das Beobachtungs-Register). Ebenfalls
  unverändert offen.

**Nicht geprüft, weil nicht Reviewer-Rolle:** die DoD-Abhakung, der Stand von `make gates`,
`make mutate` und `make full-smoke` über dem echten Baum, und ob
[ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) ihren
Acceptance-Trigger erreicht hat.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| **HIGH** | 1 | Zahn misst den Parameter, die Zusage nennt den Schalter — die Verdrahtung dazwischen ist unbewacht |
| **MEDIUM** | 1 | Wächter quantifiziert über die Vereinigung, die Zusage über jede einzelne Datei |
| **LOW** | 0 | — |
| **INFO** | 0 | — |

**Behoben aus Runde 1:** HIGH-1, MEDIUM-1, MEDIUM-2, LOW-1, LOW-2, INFO-1, INFO-2 — je mit der
Mutation nachgemessen, die dort grün blieb. **Weiter offen und korrekt delegiert:** MEDIUM-3,
MEDIUM-4 (Planner, vor dem `git mv` nach `done/`), MEDIUM-5 (Planner,
[ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).

**Die Klasse ist dieselbe geblieben, und das ist das eigentliche Signal.** Beide Findings
dieser Runde sind `BEO-025` (*eine Zusage nennt einen Geltungsbereich, den der Code darunter
nicht hält; in der schärfsten Form nennt sie einen Sensor, der genau diese Form nicht sieht*).
Sie sind **keine Wiederholung** der Runde-1-Befunde, sondern deren **Nachbarschaft**: Runde 1
traf die Zeile, Runde 2 trifft die Strecke davor bzw. die Datei daneben. Beide waren im Diff
der Runde 1 bereits vorhanden und dort nicht gefunden — das gehört hier hin, weil ein Report,
der die eigene Trefferquote verschweigt, den Steering-Loop-Zähler falsch speist. Für die
Closure §7 bleibt es **ein** Zähler-Schritt: derselbe Vorgang, dieselbe Kennung. Der Register-Stand
`BEO-025` **2×** (`awk -F'|' '/BEO-025/ {print $5}' docs/plan/planning/observations.md`, kein
Erwartungswert) erreicht mit `slice-175` die **dritte** Nennung; **ob** der Zähler-Schritt fällt
und was er auslöst, entscheidet die Closure und nicht dieser Report.

---

## Verdikt

**Nicht freigegeben für die Verifikation.** Ein HIGH und ein MEDIUM stehen; nach
`.harness/skills/reviewer.md` §Ablage blockieren beide Kategorien typischerweise.

- **HIGH-1 blockiert ohne Abweichung.** Die Eigenschaft, die einen **Blick** auf eine Welle von
  ihrer **Archivierung** trennt, ist jetzt an ihrem Parameter gemessen — aber die einzige
  Strecke, über die ein realer Aufrufer sie erreicht, liegt davor und ist unbewacht. Eine
  Ein-Zeilen-Mutation dort läuft durch `make test-go`, `make lint` und `make test-bats`, und der
  daraus gebaute Träger archiviert unter `--vorschau`, nachdem er *„der schreibende Lauf liefe"*
  gedruckt hat. Das ist derselbe Fall, den [`AGENTS.md`](../../AGENTS.md) §3.6 als *„kann unter
  keiner Mutation rot werden"* beschreibt, nur eine Aufruf-Ebene höher — und die Zusagen in
  `harness/README.md` und im Datei-Kopf sprechen ausdrücklich vom **Schalter**, nicht vom
  Parameter.
- **MEDIUM-1 blockiert den Code nicht, sondern die Zusage über seinen Wächter.** Die Operation
  ist korrekt; unvollständig ist die Deckung, die der Datei-Kopf des Wächters für die Richtung
  Code → Vorlage behauptet.

**Was trägt.** Die drei blockierenden Befunde der Runde 1 sind eingelöst, und zwar nicht dem
Wortlaut nach, sondern **unter der schärferen Mutation als der gelisteten**: der Guard
vollständig entfernt, der `FormOK`-Aufruf vollständig entfernt, der Platzhalter in der
vendored Vorlage umbenannt — alle drei jetzt rot am benannten Wächter. Der neue Vorschau-Fall
ist gegen den einzigen Baum gebaut, an dem er etwas aussagt, benennt seine Vorbedingung als
einziges `Fatal` und hat eine Gegenprobe, die ihn vor dem wirkungslosen Grün schützt. Die
Extraktion des Vorlagen-Wächters fällt bei einer unbekannten Form, statt sie zu überspringen,
und trägt einen zweiten Fall über ihrer eigenen Deckung. Vier Mutations-Fälle mit auflösendem
`expect` und treffendem Muster sind dazugekommen. Die vier nachgezogenen Aussagen stehen im
Indikativ über den Zustand.

**Kein Rollen-Konflikt erkennbar.** Sollte die Implementation HIGH-1 mit dem Argument
bestreiten, die Eigenschaft sei „doch getestet", greift der Konflikt-Pfad aus Modul 8
§Konflikt-Pfad als Rollen-Sequenz (Reviewer → Architect → Verdikt als Artefakt); die
Herabstufung eines Findings, weil die Implementation widerspricht, ist dort ausdrücklich der
vierte, falsche Pfad. Der Befund ist an einer Sonde gemessen und nicht abgeleitet — das
Gegenbeispiel dazu wäre ein grüner Lauf derselben Mutation, nicht eine Einschätzung.

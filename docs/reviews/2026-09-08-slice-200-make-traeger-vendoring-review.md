# Review — slice-200: Das eigene Vendoring bekommt seinen `make`-Träger

**Rolle:** Reviewer (Modul 8) · **Datum:** 2026-09-08 · **Runde:** 1

**Prüfgegenstand:** `fbc59a95` (reiner Move), `3ceb052e` (Ruhe-Marker), `ae29fe55` (Umsetzung).
`HEAD` = `ae29fe55`, Arbeitsbaum sauber (`git status` → *nichts zu committen*), gemessen vor und
nach diesem Lauf.

**Prüfgrundlage:** der Slice-Plan `slice-200` (Kennung, nicht Adresse — die Datei wandert),
die im Diff genannten aktiven ADRs (`ADR-0003` Accepted, `ADR-0007` Accepted), die Hard Rules
`AGENTS.md` §3, der Adaptions-Block (`MR-007`, `MR-025`) und die Anforderungen `LH-QA-01`,
`LH-QA-02`, `LH-QA-03`, `LH-FA-09`. **Nicht** geprüft: die DoD-Abhakung — das ist die
Verifikation.

**Vorherige Findings am gleichen Modul:** der Review zu `slice-193` (derselbe vendored Baum,
derselbe Pin-Satz) und die Reports zu `slice-197`; aus ihnen stammt die Klasse
*vendored Baum entsteht aus anderer Quelle als sein Pin*, die dieser Slice adressiert.

**Gate-Stand:** `make gates` vor dem Review Exit 0 (`baseline-verify: v6.5.0 OK — 54 Dateien`,
`d-check: 962 Datei(en) geprüft, 0 Befund(e)`, `comment-claims: 57 Datei(en) geprueft, 0
Befund(e)`), nach dem Review erneut Exit 0 — siehe §Gate-Lauf nach dem Review.

---

## Findings

### HIGH-1 — Der Test-Kommentar nennt ein Gegenbeispiel, das den Test nicht rot färbt

- **kategorie:** HIGH
- **quelle:** `AGENTS.md` §3.6, `AGENTS.md` §3.7
- **pfad:** `cmd/ai-harness-init/vendor_baseline_test.go:195-201`
- **befund:** Der Kommentar über `TestSubkommandoRouting_VendorBaselineFaelltNichtInDenInitPfad`
  sagt: *„Ohne den `case` wäre der Name in run() ein Positionsargument, und der Init-Pfad schriebe
  in das Arbeitsverzeichnis."* Gemessen ist das Gegenteil: Entfernt man `case "vendor-baseline":`
  samt Rumpf aus `cmd/ai-harness-init/main.go`, bleibt der Go-Satz vollständig grün. Die Sperre in
  `run()` (`cmd/ai-harness-init/main.go:176`) beantwortet **jedes** Positionsargument mit Exit 2,
  leerem stdout und ohne Schreibzugriff — alle drei Zusicherungen des Falls (Exit 2 · stdout leer ·
  Arbeitsverzeichnis trägt nur `.git`) halten mit und ohne den `case`. Der Fall misst damit nicht
  die Eigenschaft, die sein Name und sein Kommentar behaupten. Die Form des Satzes ist zusätzlich
  die verworfene Alternative im Konjunktiv, die §3.7 als eigenes Beispiel führt.
- **verifizierbar:** ja, in der Gegenprobe. Über einer Kopie des Baums außerhalb des Repos, in der
  die zwei Zeilen des `case` entfernt sind: `make test-go` → **Exit 0**, alle acht Pakete `ok`.
  **Kein Gate-Lauf über dem eingereichten Baum bestätigt den Befund** — er entsteht erst in der
  Mutation. Über derselben Kopie färbt `make test-bats` rot (`not ok 230 jedes Unterkommando hinter
  $(HOST_BIN) steht im Dispatch von main()`, `test/unterkommando-kopplung.bats`): Die Eigenschaft
  *ist* gedeckt, nur nicht von dem Fall, der sie für sich reklamiert.
- **klasse:** `kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`

### HIGH-2 — Zahl ohne Kommando, und die Zahl misst eine andere Menge als der Satz nennt

- **kategorie:** HIGH
- **quelle:** `MR-025` Setzung 1
- **pfad:** `harness/README.md:121`
- **befund:** Der Absatz führt sich als Beleg ein (*„Der Anlass ist gemessen, nicht vermutet"*) und
  sagt: *„die zwei Quellen unterschieden sich in 26 Dateien"*. Im selben Absatz steht kein Kommando,
  das genau diese Zahl ausgibt, und auch nicht die Angabe, dass keines sie liefert. Ihre Quelle ist
  die Closure-Notiz von `slice-193`; dort trägt sie
  `git grep -l '\.\./\.\./kurs/de/' 962c1722^ -- '.harness/baseline/v6.5.0' | wc -l`. Dieses
  Kommando zählt die Dateien, die **eine** Link-Form tragen — nicht die Dateien, in denen sich die
  zwei Quellen unterscheiden. Für den Satz im README ist die 26 damit eine Untergrenze und keine
  Größe.
- **verifizierbar:** **nein** durch einen Gate-Lauf — `.d-check.yml` führt kein Modul, das Zahlen
  gegen einen Lauf hält, und `MR-025` stellt diese Lücke für sich selbst fest (§Kein Wächter, und
  das gehört dazu). Von Hand gefahren: das Kommando gibt über `962c1722^` **26** aus und über `HEAD`
  **0**; gemessen wird dabei die Link-Form, nicht die Differenz zweier Quellen.
- **klasse:** `zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`

### MEDIUM-1 — „kein zweites legt sich daneben" hält nur über demselben Tag

- **kategorie:** MEDIUM
- **quelle:** `AGENTS.md` §3.6 (*die Zusage auf das einschränken, was der Code hält*), `MR-007`
  Setzung 4
- **pfad:** `cmd/ai-harness-init/vendor_baseline.go:34-35`, `cmd/ai-harness-init/main.go:87`,
  `Makefile:351`, `harness/README.md:119`
- **befund:** Vier Stellen sagen *„ein vorhandenes `<tag>`-Verzeichnis wird ersetzt, kein zweites
  legt sich daneben"*. Gemessen am Produkt-Binär über einem abweichenden Tag:
  `make vendor-baseline BASELINE_TAG=v6.0.0 BASELINE_ZIP_SHA256=ed617e38…` endet mit **Exit 0** und
  der Meldung *„…/.harness/baseline/v6.0.0 vendored (aus dem verifizierten Asset)"* und legt
  `v6.0.0/` **neben** `v6.5.0/`; `make baseline-verify` danach: *„FEHLER: mehr als ein
  `<tag>`-Verzeichnis unter .harness/baseline/"*, Exit 1 — damit `make gates` rot. Der Grund liegt
  in `internal/fetch.Baseline` (`final := filepath.Join(destDir, tag)`): konvergent ist der Lauf
  über **demselben** Tag. Genau der abweichende Tag ist der Fall, für den der Slice-Plan §1 den
  Träger begründet (*„Ohne Träger entsteht der Fehler beim nächsten Sprung wieder"*). Die
  README-Stelle nennt die Tag-Koexistenz daneben als *„bleibt außerhalb"* — als Abgrenzung des
  Umfangs, nicht als das, was ein Lauf über einem anderen Tag tut; die drei anderen Stellen nennen
  sie gar nicht.
- **verifizierbar:** ja — der Lauf oben und `make baseline-verify` danach (Exit 1). Beides in diesem
  Review gefahren; das zweite `<tag>`-Verzeichnis ist danach entfernt, der Fingerabdruck von
  `.harness/baseline/` ist vor und nach dem Review identisch
  (`find .harness/baseline -type f | sort | xargs sha256sum | sha256sum`).
- **klasse:** `zusage-nennt-sensor-der-form-nicht-sieht`

### LOW-1 — Drei Stellen beschreiben den Stand vor dem Commit statt den Stand der Stelle

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.7
- **pfad:** `cmd/ai-harness-init/vendor_baseline.go:4`, `Makefile:348`, `harness/README.md:119`
- **befund:** Drei Stellen sagen *„hatte bislang genau EINEN Aufrufer … dieser Zweig ist der
  zweite"*. Der Zustand am Baum ist: `fetch.Baseline` hat außerhalb der Tests zwei Aufrufer
  (`git grep -n 'fetch\.Baseline(' -- cmd internal | grep -v _test` →
  `cmd/ai-harness-init/main.go:379` und `cmd/ai-harness-init/vendor_baseline.go:72`). Die Aussage
  ist im Perfekt über einen abgelösten Zustand geführt; ein dritter Aufrufer lässt sie an drei
  Orten falsch stehen, ohne dass ein Lauf davon spricht.
- **verifizierbar:** **nein** — `make comment-claims` prüft die Existenz eines genannten Sensors,
  nicht den Gegenstand eines Kommentars, und `Makefile` sowie jede Markdown-Datei liegen dauerhaft
  außerhalb seines Prüfbereichs (`harness/README.md` §Was `comment-claims` nicht deckt, Punkt 2).
- **klasse:** `kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`

### LOW-2 — Die neue Verdrahtung trägt keinen Fall in `test/mutations/`

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.6 (*wer keinen Fall in `test/mutations/` hat, ist unbewacht*)
- **pfad:** `test/mutations/` (kein Fall nennt `cmd/ai-harness-init/vendor_baseline.go`)
- **befund:** `ls test/mutations/*vendor*` ist leer (Exit 2), und kein vorhandener Fall nennt die
  neue Datei (`grep -l 'vendor_baseline' test/mutations/*.sh` ist leer). Verliert einer der acht
  Fälle aus `cmd/ai-harness-init/vendor_baseline_test.go` seine Zähne, meldet `make mutate` das
  nicht. Zwei Hälften sind davon ausgenommen und gemessen: die Fähigkeit darunter trägt fünf Fälle
  (`grep -l 'internal/fetch/baseline.go' test/mutations/*.sh | wc -l` → **5**), und die
  Dispatch-Kopplung fängt `test/unterkommando-kopplung.bats` (in diesem Review rot gesehen, siehe
  HIGH-1). Unbewacht bleibt die Verdrahtung in `vendorBaselineMit` — Wurzel-Auflösung, Zielpfad,
  Exit-Codes — und die Argument-Übergabe im Rezept.
- **verifizierbar:** ja, negativ: `make mutate` läuft grün, ohne über diese Datei geurteilt zu
  haben. In diesem Review **nicht** gefahren — `mutate` steht außerhalb von `make gates`.
- **klasse:** `neuer-waechter-ohne-mutations-fall` — der nächstliegende vorhandene Eintrag
  `mutations-fall-deckt-den-lauten-statt-den-stillen-pfad` deckt ihn nicht: dort existiert ein Fall
  und trifft die falsche Stelle, hier existiert keiner.

### INFO-1 — Die eskalierte Frage: `AGENTS.md` §4 wurde zu Recht nicht angefasst

- **kategorie:** INFO
- **quelle:** Plan `slice-200` §3, `LH-QA-01`
- **pfad:** `AGENTS.md` §4 (unberührt), `harness/README.md:119-121`
- **befund:** Die Begründung des Implementers trägt, gemessen: Die Tabelle in §4 nennt genau die
  zehn Voraussetzungen von `record-gates` plus `make gates` —
  `awk '/^## 4\. Quality Gates/,/^## 5\./' AGENTS.md | grep -oE 'make [a-z-]+' | sort -u` → 11
  Namen, und `sed -n 's/^record-gates: \(.*\)  *##.*/\1/p' Makefile` → dieselben zehn.
  `slice-mv` und `archive-welle` — die zwei herstellenden Nachbarn — stehen dort **nicht**; ihre
  Beschreibung liegt allein in `harness/README.md`. Ein nicht-prüfendes Ziel in diese Tabelle zu
  setzen liefe gegen `LH-QA-01`. Der Plan-Punkt §3 ist damit der Fehler und gehört in die
  Closure-Notiz. **Rest, nicht von diesem Diff verursacht:** Die Aufzählung in §4, *„welche
  außerhalb von `make gates` stehen (`smoke`, `full-smoke`, `mutate`, `span-report`,
  `hook-overhead`)"*, führt `slice-mv` und `archive-welle` schon vorher nicht; `vendor-baseline`
  ist der dritte Nicht-Genannte. `AGENTS.md` ist in diesem Diff unberührt, der Bestand ist kein
  Arbeitsauftrag dieses Slice.

### INFO-2 — Plan §6 verlangt „in die vorhandene Tabelle", geliefert ist ein Absatz

- **kategorie:** INFO
- **quelle:** Plan `slice-200` §6, zweites Risiko
- **pfad:** `harness/README.md:119-121`
- **befund:** Das zweite Risiko des Plans schließt mit *„schreibt seine Beschreibung darum in die
  vorhandene Tabelle"*. Geliefert sind zwei Prosa-Absätze nach dem `archive-welle`-Block. Die
  einzige Tabelle, die in Frage käme, ist §Sensors (Feedback-Gates) in `harness/README.md`, und sie
  führt ausschließlich Gates; die zwei herstellenden Nachbarn stehen dort ebenfalls als Absatz. Die
  Abweichung folgt der Form der Nachbarn und der Einordnung des Ziels; die Plan-Formulierung ist
  der zweite Punkt für die Closure-Notiz.

### INFO-3 — Die Zahl 8 trägt ihr Kommando, aber eine andere Bezugsmenge als der Satz

- **kategorie:** INFO
- **quelle:** `MR-025` Setzung 1
- **pfad:** `harness/README.md:121`
- **befund:** *„die Verdrahtung selbst — Repo-Wurzel, Ersetzen eines vorhandenen
  `<tag>`-Verzeichnisses, Aufruf-Fehler bei fehlenden Argumenten und der `main()`-Dispatch-Zweig —
  deckt dieselbe Datei in **8** Fällen"*, mit Kommando und als *kein Erwartungswert* markiert. Das
  Kommando gibt **8** aus (nachgefahren). Die Bezugsmenge des Satzes ist aber enger als die des
  Kommandos: Der `sha256`-Fall, den der Satz davor eigens nennt, ist einer der acht, ebenso der
  Parser- und der Help-Fall. Form und Wert sind erfüllt, die Zuordnung *Verdrahtung → 8* ist es
  nicht.

---

## Negativbefunde — geprüft, ohne Befund

1. **Reproduktion über dem gepinnten Tag.** `make vendor-baseline` gefahren (Exit 0). Danach:
   `git status --porcelain -- .harness/baseline/` leer, Fingerabdruck
   (`find .harness/baseline -type f | sort | xargs sha256sum | sha256sum`) vor und nach dem Lauf
   identisch (`bee62754…`), `ls -d .harness/baseline/v*/ | wc -l` → **1**, keine `.baseline-*`-Reste
   (`ls -a .harness/baseline/` zeigt nur `v6.5.0`). `make baseline-verify` danach:
   `v6.5.0 OK — 54 Dateien`, Exit 0. Der tragende Beleg des Slice reproduziert.
2. **Gegenbeispiel `sha256`, am Produkt-Binär.**
   `.harness/state/bin/ai-harness-init vendor-baseline v6.5.0 000…0` → **Exit 1**, Meldung
   *„baseline v6.5.0: sha256 000…0 erwartet, 80684c17… erhalten — Asset veraendert oder falscher
   Pin (LH-QA-02)"*, stdout leer, Baum unverändert (Fingerabdruck identisch). Der Abbruch liegt vor
   jedem Schreibzugriff — `internal/fetch.Baseline` prüft den Hash vor `os.MkdirAll`. Die Zusage
   *„bricht ab, bevor er etwas anfasst"* trägt.
3. **Gegenbeispiel über das `make`-Ziel.** `make vendor-baseline BASELINE_ZIP_SHA256=000…0` →
   dieselbe Meldung, `make: *** [Makefile:362: vendor-baseline] Fehler 1`, Baum unverändert. Der
   überschriebene Wert wirkt — der Pin reist wirklich als Argument, nicht als eingebetteter Wert.
4. **Kein sechster Pin-Ort.**
   `git grep -n 'v6\.5\.0\|80684c17…' -- Makefile cmd internal .d-check.yml d-check.mk ':!*_test.go' ':!.harness/baseline'`
   liefert genau die fünf bekannten Stellen (`Makefile:25`, `Makefile:34`, `.d-check.yml:240-241`,
   `internal/fetch/baseline.go:48`, `internal/fetch/baseline.go:54`). `vendor_baseline.go` trägt
   keinen Tag- und keinen `sha256`-Wert. Die fail-closed-Kopplung der fünf ist unberührt.
5. **`internal/fetch` unberührt, keine zweite Fassung.**
   `git show --pretty=format: --name-only ae29fe55` nennt keine Datei unter `internal/`.
   `vendorBaselineMit` ruft `fetch.Baseline` und trägt darüber hinaus nur Argument-Parsen,
   Wurzel-Auflösung (`repoWurzel` aus `archive_welle.go`, wiederverwendet) und Zielpfad
   (`baselineDir` aus `main.go`, wiederverwendet). Der Plan-Punkt §3 *„vermutlich unberührt"* ist
   eingehalten.
6. **Unterkommando-Kopplung.** Das Rezept nennt den Träger in der Form, die
   `test/unterkommando-kopplung.bats` liest, und `case "vendor-baseline":` steht als Marke am
   Zeilenanfang im Dispatch. Der Fall läuft grün über dem eingereichten Baum und rot über der Kopie
   ohne den `case` — beide Richtungen gemessen.
7. **Einordnung außerhalb `make gates` (`LH-QA-01`).** `vendor-baseline` steht nicht in
   `record-gates` und in keiner Prerequisite-Kette; kein Ziel im `Makefile` nennt es als
   Voraussetzung (`grep -nE '^[a-z0-9-]+:.*vendor-baseline' Makefile` leer). Es stellt her und
   prüft nicht, und es braucht Netz — dieselbe Begründung, mit der `regelwerk-check` und
   `baseline-freshness` draußen stehen. Trägt.
8. **ADR-Bezüge aktiv.** `ADR-0003` und `ADR-0007` tragen beide `**Status:** Accepted`; keine
   superseded oder deprecated ADR wird referenziert. Ein neuer Architektur-Beschluss ist nicht
   nötig: `ADR-0022` Festlegung 2 führt Träger und Unterkommando bereits als Präzedenz.
9. **Zwei-Commit-Trennung (§3.3).** `fbc59a95` ist ein reiner Move (0 Insertions/Deletions),
   `3ceb052e` und `ae29fe55` tragen Inhalt. Getrennt.
10. **`usage`-Vollständigkeit.** Der neue Name steht in der Kurzform (`main.go:42`) und im
    Subkommando-Block (`main.go:83-88`); `TestUsageNenntAlleVierUnterkommandos` ist mitgezogen. Die
    GRENZE-Notiz vor `run()` ist auf vier Namen nachgeführt und beschreibt den Ist-Zustand.
11. **Timeout-Wert.** `120*time.Second` ist der Wert, den die vorhandenen Netz-Aufrufe im selben
    Paket führen (`git grep -n 'WithTimeout' -- cmd internal | grep -v _test`) — kein abweichender
    neuer Wert.
12. **Roadmap-Ruhe-Marker (`3ceb052e`).** Die Entfernung ist die mechanische Folge des Move nach
    `in-progress/`; das Modul `planning` in `.d-check.yml` hält beide Richtungen und ist grün. Der
    Commit trägt nur diese Datei. Keine Quelle dieses Repos weist die Marker-Hälfte einer Rolle zu
    — die Frage bleibt offen, sie ist hier kein Befund.
13. **Fehlerpfad-Zusagen im Usage-Text.** *„bei Mismatch/Entpack-Fehler bleibt ein bestehender Baum
    UNVERAENDERT"* — trägt: bis `placeBaseline` wird nur unter einem `.baseline-*`-Temp gearbeitet,
    das ein `defer` auf jedem Fehlerpfad räumt. Die eine Einschränkung, die `internal/fetch` selbst
    benennt (`destDir` wird früh angelegt), betrifft nicht *„ein bestehender Baum"*.
14. **Docker-only (§3.9).** Kein Host-Paketmanager und keine Host-Toolchain in der Befehlsposition;
    das Rezept ruft den Produkt-Träger, den `host-bin` im gitignorierten Zustands-Bereich baut.
15. **Kein Lint-Suppression (§3.2).** Kein `//nolint`, kein `# shellcheck disable` im Diff;
    `make lint` und `make shell-lint` grün.

---

## Gate-Lauf nach dem Review

`make gates` → **Exit 0**; `d-check: 963 Datei(en) geprüft, 0 Befund(e)` (962 vor dem Report, plus diese Datei),
`baseline-verify: v6.5.0 OK — 54 Dateien`, `comment-claims: 57 Datei(en) geprueft, 0 Befund(e)`.
Der Arbeitsbaum ist nach diesem Review bis auf diese Report-Datei unverändert; die drei
Vendoring-Läufe und das zweite `<tag>`-Verzeichnis aus MEDIUM-1 sind zurückgenommen (Fingerabdruck
von `.harness/baseline/` identisch zum Stand vor dem Review).

**Eigenmessung dieser Datei** (Auflage): Sie trägt **keinen** Markdown-Link — weder in den vendored
Baum noch sonstwohin. Gemessen mit `grep -cE '\]\(' <diese Datei>` → **0**; das Muster ist escaped
geschrieben und trifft darum die Zeile nicht, in der es selbst steht. Die Deklaration
`# Deckung: 33` für das Paar `docs/reviews/**` × `.harness/baseline/**` in `.d-check.yml` bleibt
damit unberührt; `test/ignore-refs-restbreite.bats` ist im obigen `make gates`-Lauf grün.

---

## Kategorie-Summary

| Kategorie | Anzahl | Kennungen |
|---|---|---|
| HIGH | 2 | HIGH-1 (Test-Kommentar nennt ein Gegenbeispiel, das nicht rot färbt) · HIGH-2 (Zahl ohne Kommando, andere Bezugsmenge) |
| MEDIUM | 1 | MEDIUM-1 (Zusage „kein zweites legt sich daneben" hält nur über demselben Tag) |
| LOW | 2 | LOW-1 (Perfekt über abgelösten Zustand, drei Stellen) · LOW-2 (keine Mutations-Fälle für die neue Verdrahtung) |
| INFO | 3 | INFO-1 (`AGENTS.md` §4 zu Recht unberührt) · INFO-2 (Plan §6 „Tabelle" vs. Absatz) · INFO-3 (Bezugsmenge der 8) |

**Wiederkehrende Klasse in dieser Sitzung:**
`kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle` tritt zweimal auf (HIGH-1, LOW-1)
— innerhalb *eines* Vorgangs also eine Gelegenheit und ein Beleg, kein zweiter Zähler-Schritt. Der
Eintrag steht im Beobachtungs-Register bei zwei Belegen
(`ls docs/plan/planning/observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/evidence/*.md | wc -l`
→ **2**, kein Erwartungswert); mit diesem Vorgang erreicht er **3×** und damit die Schwelle. Das
Urteil darüber fällt der Lese-Schritt der Closure, nicht dieser Report.

---

## Verdikt

**Blockiert.** Zwei HIGH und ein MEDIUM stehen offen.

Der tragende Beleg des Slice **reproduziert**: Der Lauf über dem gepinnten Tag lässt den vendored
Baum um kein Byte anders, `make baseline-verify` meldet danach `OK`, und beide bezeugten
Gegenbeispiele sind in diesem Review am Produkt-Binär nachgefahren. Die Form ist die zugesagte —
ein dünner Draht auf ein unverändertes `internal/fetch.Baseline`, kein sechster Pin-Ort, keine
zweite Fassung der Operation, die Einordnung außerhalb von `make gates` trägt gegen `LH-QA-01`.

Was blockiert, sind Aussagen **über** diese Arbeit, nicht die Arbeit: ein Test-Kommentar, dessen
benanntes Gegenbeispiel den Test nicht rot färbt (`AGENTS.md` §3.6 verlangt genau das, und die
Gegenprobe ist gefahren), eine Beleg-Zahl ohne ihr Kommando, deren Bezugsmenge eine andere ist als
der Satz sagt, und eine viermal wiederholte Zusage, die über einem abweichenden Tag messbar nicht
hält — in genau dem Fall, für den der Träger gebaut wurde.

Die eskalierte Frage ist entschieden: `AGENTS.md` §4 gehörte nicht angefasst; der Plan-Punkt ist
der Fehler und gehört mit INFO-2 in die Closure-Notiz.

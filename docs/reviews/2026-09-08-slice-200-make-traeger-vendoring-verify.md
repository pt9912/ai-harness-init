# Verifikation — slice-200: Das eigene Vendoring bekommt seinen `make`-Träger

**Rolle:** Verifier (Modul 11) · **Datum:** 2026-09-08

**Prüfgegenstand:** `HEAD` = `ac098942`, Arbeitsbaum sauber (`git status --porcelain` leer), gemessen
vor und nach diesem Lauf. Slice-Commits: `fbc59a95` (Move), `3ceb052e` (Ruhe-Marker), `ae29fe55`
(Umsetzung), `36937d90` (Review, blockierend), `ac098942` (Befund-Behebung).

**Prüfgrundlage:** Slice-Plan `slice-200` (Kennung, nicht Adresse), sein Review-Report
(`2026-09-08-slice-200-make-traeger-vendoring-review.md`, Verdikt *Blockiert*, 2 HIGH/1 MEDIUM),
`AGENTS.md` §3.6/§3.7/§3.9, `MR-007` Setzung 4, `ADR-0003`/`ADR-0007`. **Nicht** geprüft: Plan
gegen ADR/Hard Rules — das war Review; ich prüfe DoD/Closure-Trigger gegen das, was der Code tut,
und Plan-vs-Code.

**Ich bin der erste Kontext, der die DoD prüft** — der Reviewer hat sie ausdrücklich ausgenommen.

---

## Gate-Stand (selbst gefahren)

`make gates` → **Exit 0**. `baseline-verify: v6.5.0 OK — 54 Dateien`, `d-check: 963 Datei(en)
geprüft, 0 Befund(e)`, `comment-claims: 57 Datei(en) geprueft, 0 Befund(e)`. Deckt sich mit dem im
Review-Report protokollierten Stand.

---

## DoD, Punkt für Punkt

1. **Ein `make`-Ziel legt den vendored Baum aus dem verifizierten Asset an, Träger statt
   Host-Werkzeug, liest Tag/`sha256` aus den kanonischen Makefile-Variablen.** — **erfüllt.**
   `grep -nE '^BASELINE_(TAG|ZIP_SHA256)' Makefile` → `BASELINE_TAG ?= v6.5.0`,
   `BASELINE_ZIP_SHA256 ?= 80684c17…`; das Rezept übergibt beide als Argumente
   (`vendor-baseline: host-bin` → `$(HOST_BIN) vendor-baseline "$(BASELINE_TAG)"
   "$(BASELINE_ZIP_SHA256)"`), kein Host-Paketmanager in der Befehlsposition. Nach `make
   vendor-baseline`: `make baseline-verify` → `v6.5.0 OK — 54 Dateien`, `ls -d
   .harness/baseline/v*/ | wc -l` → `1`.
2. **Reproduzierbar, byte-gleich; falscher `sha256` färbt rot.** — **erfüllt**, unabhängig
   nachgefahren, siehe §Closure-Trigger unten.
3. **`make gates` grün.** — **erfüllt**, siehe §Gate-Stand.
4. **Review durchgeführt, Report liegt vor.** — **erfüllt**:
   `docs/reviews/2026-09-08-slice-200-make-traeger-vendoring-review.md`, Rollenwechsel gewahrt
   (Reviewer ≠ Implementer ≠ dieser Lauf).
5. **Doku-Update, falls öffentlicher Vertrag berührt.** — **erfüllt**: `Makefile`-Kopfkommentar und
   `harness/README.md` beschreiben das neue Ziel; `AGENTS.md` §4 bleibt unberührt (dazu unten,
   zweite Feststellung).
6.–10. **Closure-Notiz, Beobachtungs-Register, Risiko-Ausgänge, drei Paarungen.** — **noch nicht
   fällig.** Der Slice liegt weiter in `in-progress/`, die DoD-Checkboxen sind unverändert
   unangehakt. Das ist korrekt: Closure ist nach `AGENTS.md` §3.10 Planner-Arbeit in eigenem
   Kontext, nicht Teil dieses Laufs oder des Implementer-Laufs. Diese fünf Punkte sind damit nicht
   „nicht erfüllt", sondern **außerhalb des Prüfgegenstands dieses Laufs**.

---

## Die zwei Closure-Trigger-Kriterien (§5) — unabhängig gefahren

**Kriterium 1 — Reproduktion über dem gepinnten Tag.**

```
$ find .harness/baseline -type f | sort | xargs sha256sum | sha256sum
bee62754…   (vor dem Lauf)
$ make vendor-baseline   # Exit 0
$ find .harness/baseline -type f | sort | xargs sha256sum | sha256sum
bee62754…   (nach dem Lauf — byte-identisch)
$ git status --porcelain -- .harness/baseline/    # leer
$ ls -d .harness/baseline/v*/ | wc -l              # 1
$ ls -a .harness/baseline/                         # nur v6.5.0, kein .baseline-*-Rest
$ make baseline-verify
baseline-verify: v6.5.0 OK — 54 Dateien
```

**Trägt.** Derselbe Fingerabdruck wie im Review-Report protokolliert.

**Kriterium 2 — Gegenbeispiel `sha256`, am Produkt-Binär, nicht am Test.**

```
$ .harness/state/bin/ai-harness-init vendor-baseline v6.5.0 0000…0
stdout: (leer)
stderr: vendor-baseline: baseline v6.5.0: sha256 0000…0 erwartet, 80684c17… erhalten —
        Asset veraendert oder falscher Pin (LH-QA-02)
Exit: 1
```

Fingerabdruck von `.harness/baseline/` vor und nach diesem Lauf identisch (`bee62754…`), kein
zweites Verzeichnis. Die gelesene Meldung benennt Ursache und LH-Bezug, stdout bleibt leer, der
Abbruch liegt vor jedem Schreibzugriff. **Trägt.**

---

## MEDIUM-1-Fix (`fremderTagVorhanden`) — Sperre am Produkt gemessen

Neues Verzeichnis mit fremdem Tag (`v6.0.0`) unter `.harness/baseline/` angelegt, Marker-Datei
mit definiertem Inhalt, dann `ai-harness-init vendor-baseline v6.5.0 <richtiger-sha256>` in diesem
Baum gefahren:

```
Laufzeit: 0,003 s
stderr:  vendor-baseline: …/.harness/baseline enthaelt bereits "v6.0.0" (ein anderer Tag) —
         dieses Ziel ersetzt nur v6.5.0 selbst, ein Tag-Wechsel bleibt ausserhalb
         (MR-007 Setzung 4: ein Tag zur Zeit); …/v6.0.0 von Hand entfernen und den
         Lauf wiederholen.
Exit: 1
Fingerabdruck vor/nach: identisch. Marker-Datei-Inhalt: unverändert.
```

**Kein Netz-Aufruf:** Die Laufzeit von 3 ms ist mit einem Asset-Fetch nicht vereinbar, und im Code
sitzt der Aufruf von `fremderTagVorhanden` (reines `os.ReadDir`) **vor** dem einzigen
Netz-Aufrufpunkt (`fetch.Baseline`) — dieselbe Reihenfolge, die
`TestVendorBaselineMit_AndererTagBrichtAbOhneSchreibzugriff` mit einem Fetch-Double erzwingt, das
bei Aufruf einen Fehler wirft (`darf nicht laufen`). Die Zusage aus dem Bericht *„kein Netz-Aufruf"*
trägt.

**`MR-007` Setzung 4 hält danach:** Die Setzung verlangt „ein Tag zur Zeit (Ersetzen), Historie in
`git`". Vor dem Fix legte ein Tag-Bump-Lauf ein zweites Verzeichnis daneben (Review MEDIUM-1); nach
dem Fix bricht er ab, bevor das zweite Verzeichnis entsteht — die Koexistenz, die die Setzung
verbietet, kann jetzt nicht mehr entstehen. Die Setzung selbst ist unverändert.

---

## Die Zahl 28 in `harness/README.md`

```
$ git diff --name-only 962c1722^ 962c1722 -- .harness/baseline/v6.5.0 | grep -v SHA256SUMS | wc -l
28
```

Kommando steht im selben Absatz wie die Zahl, liefert exakt **28**. Anders als die vorige Fassung
(„26 Dateien", Kommando `git grep -l '\.\./\.\./kurs/de/' … | wc -l` — zählte eine **Link-Form**,
nicht die Differenz zweier Quellen) misst dieses Kommando jetzt tatsächlich, was der Satz behauptet:
den Diff zwischen den zwei Tree-Operanden des Tausch-Commits, ohne die derivative `SHA256SUMS`. Da
`962c1722^`/`962c1722` fixe Commits sind, ist die Zahl an sie gebunden und wandert nicht mit dem
Bestand — die Fest-Begründung im Text trägt. Dritte Fassung dieser Zahl, jetzt mit korrektem
Gegenstand: kein neuer Befund derselben Klasse.

Nebenbefund, nicht blockierend: Der ursprüngliche Tausch-Commit (`slice-193`) selbst nennt in seiner
Commit-Message „29 Dateien" für eine dritte, wieder andere Bezugsmenge (Dateien mit
`../../kurs/de/`-Verweisen). Das ist eine eingefrorene Commit-Message und kein lebendes Artefakt —
`MR-025` bindet nicht rückwirkend, kein Befund gegen diesen Slice.

---

## Mutations-Fall `test/mutations/276-vendor-baseline-anderer-tag-sperre.sh`

Isolierte Kopie außerhalb des Repos (`git archive HEAD | tar -x`), Mutation angewendet
(`if fremd != "" {` → `if false && fremd != "" {`), dann `make test-go` (Docker-only, Dockerfile
`test`-Stage) über der mutierten Kopie:

```
--- FAIL: TestVendorBaselineMit_AndererTagBrichtAbOhneSchreibzugriff (0.00s)
    vendor_baseline_test.go:168: Asset-Fetch lief trotz anderem Tag-Verzeichnis
    vendor_baseline_test.go:174: stderr nennt den gefundenen fremden Tag nicht: "vendor-baseline: darf nicht laufen\n"
FAIL	github.com/pt9912/ai-harness-init/cmd/ai-harness-init	0.166s
ok  	… (alle sieben übrigen Pakete)
```

Genau der im Fall deklarierte `expect:`-Name färbt rot, kein anderes Paket kollateral. Der Fall
trifft seine Stelle — kein Fall, der sich selbst misst.

---

## Feststellung 1 — LOW-2 bleibt teilweise offen

Bestätigt: `grep -l 'vendor_baseline' test/mutations/*.sh` liefert genau eine Datei — den neuen
Fall für `fremderTagVorhanden`. Für `vendorBaselineMit` im Übrigen (Wurzel-Auflösung, Zielpfad,
Exit-Codes, die Argument-Übergabe im Rezept `$(BASELINE_TAG)`/`$(BASELINE_ZIP_SHA256)`) existiert
kein Fall — vertauschte man die zwei Rezept-Argumente oder bräche die Wurzel-Auflösung, meldete
`make mutate` nichts Neues (der geteilte `repoWurzel` aus `archive_welle.go` bleibt über dessen
eigene Fälle indirekt gedeckt; die spezifische Verdrahtung in `vendorBaselineMit` nicht).

**Urteil:** Diese Grenze ist real, aber sie ist **keine Zusage ohne Gegenbeispiel** im Sinn von
`AGENTS.md` §3.6 — weder Code noch Doku dieses Diffs behaupten an irgendeiner Stelle, dass die
Rezept-Argument-Übergabe oder die Wurzel-Auflösung von `vendor-baseline` durch `test/mutations/`
bewacht sind; die einzige explizite, DoD-gebundene Zusage (sha256-Mismatch bricht rot, Tag-Bump
bricht rot) ist belegt. Sie ist damit ein **benannter, nicht geschlossener Rest** — dieselbe Klasse,
die der Review selbst als LOW (nicht-blockierend) einordnet und unter der Klasse
`neuer-waechter-ohne-mutations-fall` führt, für die es noch keinen Registereintrag gibt
(`ls docs/plan/planning/observations/BEO-ALL/ | grep neuer-waechter-ohne-mutations-fall` → leer).
Das ist ein Punkt für die Closure-Notiz (Beobachtungs-Register neu anlegen oder Risiko §6
weiterführen), keiner, der die Closure blockiert.

## Feststellung 2 — Plan-Punkt §3 (`AGENTS.md` §4) ist der Fehler

Eigene Messung, unabhängig vom Reviewer:

```
$ awk '/^## 4\. Quality Gates/,/^## 5\./' AGENTS.md | grep -oE 'make [a-z-]+' | sort -u | wc -l
11
$ sed -n 's/^record-gates: \(.*\)  *##.*/\1/p' Makefile
baseline-verify docs-check lint build test shell-lint ci-lint comment-claims host-bin span-check
```

Die elf Namen in `AGENTS.md` §4 sind genau die zehn `record-gates`-Voraussetzungen plus `make
gates` selbst — `grep` nach `slice-mv|archive-welle|vendor-baseline` in diesem Ausschnitt liefert
nichts. `git diff --stat aa114b01..HEAD -- AGENTS.md` ist leer: Die Datei ist über den ganzen Slice
unberührt. Die Tabelle führt ausschließlich **prüfende** Gates; ein herstellendes Ziel dort
einzutragen liefe gegen `LH-QA-01`. **Stimmt aus meiner Sicht:** Der Plan-Punkt §3 (\"`AGENTS.md`
§4 | update\") ist ein Plan-Fehler, korrekt nicht umgesetzt, und gehört als Lerneintrag
(geschärfte Plan-Vorlage oder benannte Korrektur) in die Closure-Notiz — nicht als Code-Nacharbeit.

---

## Plan-vs-Code

Der Plan sagt in §1 explizit zu, was der Code jetzt tut: *„Das Ziel ersetzt darum, es legt nicht
daneben"* — vor `ac098942` war das im Tag-Bump-Fall verletzt (Review MEDIUM-1); jetzt hält der Code
die eigene Plan-Zusage ein. Kein Scope-Zuwachs: Die explizit ausgeschlossene *„Koexistenz zweier
Tags"* bleibt ausgeschlossen — die Sperre verhindert sie, sie löst sie nicht auf (kein
Pin-Nachzug, keine Tag-Wechsel-Automatik). §3 (Dateiliste) trifft mit einer Ausnahme zu
(`AGENTS.md` unberührt statt „update", s. Feststellung 2); `cmd/ai-harness-init/main.go` und
`Makefile` wie angekündigt geändert, `internal/fetch/baseline.go` wie vorhergesagt unberührt
(`git show --pretty=format: --name-only ae29fe55 ac098942 | grep internal/` → leer). §4 Trigger
(„`make gates` grün vor Start") war laut Plan am Erstellungstag unerfüllt und wartete auf
slice-197 — inzwischen erfüllt, keine Diskrepanz. §8 Sub-Area-Zuordnung (`ALL`, GF) unverändert
zutreffend: kein Shell-Helfer entstanden, `TOOLS` bleibt unberührt.

---

## Was offen bleibt

- DoD-Punkte 6–10 (Closure-Notiz, Beobachtungs-Register-Eintrag, Risiko-Ausgänge, drei Paarungen)
  — Planner-Arbeit nach `AGENTS.md` §3.10, nicht Teil dieses Laufs.
- Der Lese-Schritt für `kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`: Das
  Register führt aktuell zwei Belege; ob dieser Vorgang den dritten liefert und die Regel damit
  verkörpert wird, entscheidet die Closure, nicht dieser Bericht.
- Feststellung 1 (LOW-2-Rest) und Feststellung 2 (Plan-Punkt §3) sind für die Closure-Notiz vorgesehen.
- LOW-1 (drei Stellen), INFO-2 (Plan sagt „Tabelle", geliefert ist Absatz) und INFO-3 (Bezugsmenge
  der Verdrahtungs-Zahl) sind vom Review als nicht-blockierend eingeordnet; LOW-1 ist mit `ac098942`
  behoben (eigene Messung: kein `EINEN Aufrufer`-Rest an den drei genannten Stellen), INFO-2/INFO-3
  bleiben unverändert stehen und benötigen kein weiteres Handeln vor Closure.

**Verdikt:** Alle für diesen Lauf fälligen DoD-Punkte (1–5) sind erfüllt, beide Closure-Trigger-
Kriterien tragen unabhängig nachgemessen, der MEDIUM-1-Fix hält am Produkt-Binär, die Zahl 28 misst
jetzt den behaupteten Gegenstand, und der neue Mutations-Fall trifft seine Stelle. Kein
blockierender Befund aus Verifier-Sicht. Übergabe an den Planner zur Closure.

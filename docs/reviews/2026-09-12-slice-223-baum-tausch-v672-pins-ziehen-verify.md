# Verifikation — slice-223: Der vendored Baum steht auf `v6.7.2`, die fünf Pins ziehen mit

- **Rolle:** Verifier (Modul 11) · **Datum:** 2026-09-12
- **Eingang:** DoD-Bestätigung des Implementers über die Commits `e488119c` (Baum-Tausch + Pins),
  `f603136b` (Adress-Nachzug Implementations-Kontext), `30508fc1` (Reviewer-Skill-Nachzug),
  `38174544` (Architect: Adaptions-Block + Buchung), plus den Review-Report
  `docs/reviews/2026-09-12-slice-223-baum-tausch-v672-pins-ziehen.md` (0 HIGH · 2 MEDIUM · 1 LOW ·
  3 INFO, „nicht blockierend", zwei Auflagen an den Planner).
- **Prüfgegenstand:** `docs/plan/planning/done/slice-223-baum-tausch-v672-pins-ziehen.md`
  gegen `HEAD=f85b20dc` (Arbeitsbaum sauber, `git status --porcelain` leer).
- **Frage dieser Rolle:** Bauen wir es richtig — gegen DoD und Spec (und die dort referenzierten
  ADRs). Nicht Gegenstand: ob der Diff dem Plan/den Hard Rules folgt (Reviewer, bereits gelaufen).
- **Kein Parallel-Lauf, `make gates` nicht erneut gefahren** (Anweisung). Stattdessen: der
  Gate-Stempel `.harness/state/gates-passed.diffsha` (`00f23151ac…`) ist **byte-identisch** mit
  `bash harness/tools/working-tree-hash.sh` über dem aktuellen, sauberen Arbeitsbaum — der Stempel
  deckt genau diesen Stand, nicht einen älteren.

---

## 1. Ist der Sensor gelaufen?

Docker-Ziele selbst gefahren, weil sie kein Parallel-Lauf-Risiko tragen (reine Lesezugriffe auf den
bereits committeten Baum):

- `make baseline-verify` → `baseline-verify: v6.7.2 OK — 54 Dateien (Integritaet + Vollstaendigkeit,
  netzlos)`, EXIT 0.
- `make regelwerk-check` (Netz, kein Gate) → `1211 Datei(en) geprüft, 0 Befund(e)`, EXIT 0 — Pin ↔
  Release-Asset unabhängig von der Reviewer-Messung nachgefahren.

Nicht erneut gefahren: `make gates` als Ganzes, `make mutate`, `make smoke`, `make full-smoke` —
Anweisung. Für `make gates` trägt der Diffsha-Abgleich oben, für die vier fail-closed gekoppelten
Tests (`test/sources-pin.bats` ×2, `TestDefaultTag_MatchesBaseline`,
`TestDefaultBaselineSHA256_MatchesMakefile`) das rot-gesehene Gegenbeispiel des Reviewers
(`.d-check.yml` auf `v6.7.1`/Null-Hash mutiert → `not ok 249/250`; `baseline.go` ebenso → beide
`--- FAIL:`, danach zurückgesetzt, `git status --porcelain` leer) — ein unabhängiger Lauf einer
anderen Rolle in frischem Kontext, kein Implementer-Selbstbericht.

**Kein Sensor fehlt beobachtbar unbelegt:** jeder in der DoD genannte Wächter existiert und ist
mindestens einmal (Reviewer oder ich) tatsächlich gelaufen — mit Ausnahme von `make mutate`/
`make smoke`/`make full-smoke`, die für diesen Slice nicht angesagt sind (kein DoD-Punkt verlangt
sie; sie stehen unter „Was ich nicht geprüft habe").

## 2. Der zentrale Punkt — die drei §1-Kommandos gegen DoD 3

Selbst gemessen, über dem Ergebnis-Stand `HEAD=f85b20dc`:

```sh
PS=( '*.md' ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
     ':!docs/plan/carveouts/done' ':!docs/plan/planning/observations' )
git grep -oE '\]\([^)]*\.harness/baseline/v6\.5\.0[^)]*\)' -- "${PS[@]}" | wc -l   # 0
git grep -lE '\]\([^)]*\.harness/baseline/v6\.5\.0[^)]*\)' -- "${PS[@]}" | wc -l   # 0
git grep -oE '`[^`]*\.harness/baseline/v6\.5\.0[^`]*`'     -- "${PS[@]}" | wc -l   # 12
```

**Bestätigt: `0 · 0 · 12`, DoD 3 sagt `0`.** Das dritte Kommando trifft:

| Datei | Zeilen | Klasse |
|---|---|---|
| `AGENTS.md` | 232, 234, 239, 382 | Präsens-Mess-Aussage, **nicht** nachgezogen (Reviewer-MEDIUM-2) |
| `.claude/commands/close-welle.md` | 25, 46 | tote `cp`-Handlungsanweisung, **kein** Ausgang (Reviewer-MEDIUM-1) |
| `harness/conventions/MR-054-…md` | 23, 31, 84 | zitierte Messung gegen den *damals* adoptierten Stand |
| `harness/conventions/MR-055-…md` | 15, 33, 35 | dito |

**Urteil: DoD 3 ist nicht erfüllt — und keiner der drei angebotenen Ausgänge trifft glatt zu.**

Das Kommando misst **nicht am Ziel vorbei**: Es zählt exakt das, was es zu zählen behauptet — rohe
Vorkommen von `.harness/baseline/v6.5.0` in Inline-Code außerhalb der eingefrorenen Bäume — und
diese Zahl ist real ungleich null. Es ist auch nicht bloß ein Artefakt einer zu groben Regex: Ich
habe jeden der 12 Treffer einzeln gelesen (oben), und keiner ist ein falsch-positiver Treffer auf
harmlosen Text.

Zugleich ist die Zusage „0" **teilweise zu eng gefasst**, und zwar für **6 der 12** Treffer:
`harness/conventions/MR-054` und `MR-055` zitieren einen historischen Messwert gegen den damals
geltenden Stand (*„die adoptierte Baseline `v6.5.0` führt diese Regel"* im Sinn von „hat zum
Meßzeitpunkt geführt") — das ist nach `MR-033`/`MR-025` Setzung 1 eine **Aussage über einen
vergangenen Zustand**, keine Adresse, und der Architect hat sie in `38174544` bewusst stehen
gelassen (Commit-Message: *„MR-054 und MR-055 zitieren Messungen gegen den damals adoptierten
Stand. Dort ist der Tag eine Aussage, keine Adresse"*). §1 des Plans selbst nennt diese Klasse
allerdings nicht als Ausnahme — der Plan sagt nur *„24 Inline-Code-Pfade … update"* (§3-Tabelle)
und diskutiert keine Tree-Operand-Ausnahme. Diese 6 Treffer sind also durch eine **im
Architect-Lauf nachträglich getroffene, sachlich begründete, aber im Plan nicht vorgesehene
Deutung** gedeckt — nicht durch DoD 3 selbst.

Die **übrigen 6** Treffer sind dagegen **echte offene Arbeit ohne Deutung**, und der Plan sagt das
selbst: DoD-Punkt 3 nennt `AGENTS.md` ausdrücklich als eine der drei Eigentümer-Klassen, die den
Nachzug „im Architect-Lauf" bekommen — der Architect-Commit `38174544` hat aber **nur**
`harness/conventions.md` und `harness/conventions/` angefasst, `AGENTS.md` gar nicht berührt
(`git log --oneline -3 -- AGENTS.md` zeigt keinen Commit dieses Slice). Ebenso nennt DoD-Punkt 3
`.claude/commands/` als Klasse „bei der Rolle, die sie ausführt" (`ADR-0028`) — auch dafür liegt
kein Commit vor; das ist exakt Reviewer-MEDIUM-1, den der Reviewer ausdrücklich **nicht**
entschieden, sondern dem Planner als Auflage übergeben hat.

**Antwort auf die gestellte Frage:** DoD 3 ist **nicht erfüllt**. Für 6 der 12 fehlenden Nullen
(`AGENTS.md` ×4, `.claude/commands/close-welle.md` ×2) ist die Lücke eine **echte offene
Liefer-Pflicht dieses Slice**, die der Plan selbst so benennt und die kein anderer Slice
übernommen hat (Reviewer hat bei MEDIUM-1 geprüft: weder `slice-224` noch `slice-153` nennen das
Tag-Segment). Für die anderen 6 (`MR-054`/`MR-055`) ist die Zusage „0" **zu eng**, weil sie den
legitimen Tree-Operand-/Historien-Fall aus `MR-040` nicht vom Nachzugs-Fall unterscheidet — das ist
aber kein Grund, den Punkt insgesamt als erfüllt zu werten, weil selbst nach Abzug dieser 6 die
Zahl `6`, nicht `0` bleibt.

## 3. DoD-Punkt für DoD-Punkt

| # | DoD-Punkt | Befund | Beleg |
|---|---|---|---|
| 1 | Vendored Baum auf `v6.7.2`, `v6.5.0` existiert nicht mehr, `baseline-verify` meldet OK | **Erfüllt.** `ls .harness/baseline/` → nur `v6.7.2`; `make baseline-verify` → `v6.7.2 OK — 54 Dateien`. Der Tag-Wechsel lief als **Rename** (55 `R0xx`-Einträge in `e488119c`, keine Delete+Add-Paare), nicht als Hand-Kopie. | selbst gefahren, s. o.; `git show e488119c --name-status \| grep -c '^R'` → 55 |
| 2 | Fünf gekoppelte Pin-Stellen tragen `v6.7.2` und den **am Asset gemessenen** sha256; `regelwerk-check` meldet 0 Befund(e) | **Erfüllt.** `Makefile:25,34`, `.d-check.yml:383,384`, `internal/fetch/baseline.go:48,54` tragen alle `v6.7.2` / `ff1f7a58596a7a2b5e406442975825692fbc0e78e56715545267d0c3c8944978`. `make regelwerk-check` → `1211 Datei(en) geprüft, 0 Befund(e)`. Die fail-closed-Kopplung ist vom Reviewer real rot gesehen (s. §1). | selbst gefahren, s. o.; `grep` oben |
| 3 | Jede lebende Adresse zeigt in den neuen Baum; Übergabe-Artefakt für die Buchung liegt vor | **Nicht erfüllt** für die Adress-Hälfte (§2 oben: `0·0·12` statt `0·0·0`). Die Buchungs-Hälfte ist erfüllt: `harness/conventions.md` §Baseline trägt `Stand: v6.7.2`, Vollzugsdatum `2026-09-12`, zwei Nachweis-Zeilen (`v6.5.0`, `v6.7.2`) mit derselben Slice-Kennung `slice-224` — Form nach `ADR-0031` Festlegung 2 (Ziel-Tag, Datum, Slice, sonst nichts) exakt eingehalten. | §2 oben; `sed -n '/^## Baseline/,/^## Adoptierte/p' harness/conventions.md` |
| — | `make gates` grün | **Nicht selbst neu gefahren** (Anweisung). Diffsha-Stempel `00f23151ac…` deckt exakt den aktuellen, sauberen Arbeitsbaum. | `cat .harness/state/gates-passed.diffsha` == `bash harness/tools/working-tree-hash.sh` |
| — | Review durchgeführt, Report liegt vor, kein Self-Review | **Erfüllt.** `docs/reviews/2026-09-12-slice-223-…md` vorhanden, Reviewer-Rolle benannt, Verdikt „nicht blockierend". | Datei gelesen |
| — | Doku-Update `harness/conventions.md` §Baseline + §Adoptierte Konventions-Quellen, als Architect-Commit | **Erfüllt.** `38174544` (Rolle Architect in der Message), berührt **ausschließlich** `harness/conventions.md`, `harness/conventions/*.md` und `docs/plan/adr/README.md`-Zeile war bereits vor diesem Slice gesetzt (ADR-0044 selbst schon `Accepted`, außerhalb dieses Slice-Diffs). §Baseline und §Adoptierte Konventions-Quellen beide aktualisiert (Diff geprüft). | `git show --stat 38174544`; Diff oben zitiert |
| — | Closure-Notiz mit Lerneintrag | **Noch offen — regelkonform.** §7 des Plans trägt ausschließlich `<…>`-Platzhalter; nach `AGENTS.md` §3.10 ist das Planner-Arbeit nach dieser Verifikation. | `sed -n '291,312p' docs/plan/planning/in-progress/slice-223-*.md` |
| — | Reconciliation-Register entfällt | **Erfüllt.** `docs/plan/planning/reconciliation.md` existiert nicht. | `ls docs/plan/planning/reconciliation.md` → Fehler |
| — | Beobachtungs-Register fortgeschrieben | **Noch offen — regelkonform**, s. Closure-Notiz. Kein Diff unter `docs/plan/planning/observations/` seit `e488119c^`. | `git diff --stat e488119c^..HEAD -- docs/plan/planning/observations/` → leer |
| — | Jedes Risiko aus §6 trägt einen Ausgang | **Noch nicht zugewiesen (Planner-Arbeit)** — für keines fehlt die Evidenz, s. §4 unten. | s. §4 |
| — | Drei Paarungen | **Nicht anwendbar** — dieses Repo fährt Wellen, die Paarungen prüft die nächste Welle-Closure, auch für diesen wellenlosen Slice (Plan §2, letzter Punkt). | — |

## 4. Risiken aus §6 — Evidenzlage, inklusive der vorab benannten Frage

1. **KONVERGENZ deckt den Tag-Wechsel nicht** — **nicht eingetreten als Defekt**: Der Tausch lief
   als sauberer Rename (s. DoD 1 oben), kein händisches Nacharbeiten nötig, keine Reste. Tragfähige
   Grundlage für „entfallen".
2. **Zwischenstand `make gates` rot zwischen Tausch und Nachzug** — **nicht als geprüfter Stand
   sichtbar geworden**: Alle vier Commits liegen in derselben lokalen Historie ohne
   Zwischen-Push-Nachweis in diesem Kontext einsehbar; ich kann nicht bestätigen, dass sie
   *zusammen* gepusht wurden (git-lokal nicht beobachtbar) — das ist eine Lücke in meiner Prüfung,
   keine im Code. Der Planner sollte das vor der Closure am Remote verifizieren.
3. **Ein Nachzug ersetzt eine historisch richtige Adresse** — **nicht eingetreten**: Reviewer hat
   alle 12 verbleibenden + alle ersetzten Inline-Pfade klassifiziert und keine Fehlklassifikation
   gefunden (Negativbefund „Punkt 2 — die Trennung selbst"); ich habe die 12 Restfälle unabhängig
   gegengelesen (§2 oben) und komme zum selben Ergebnis. Tragfähige Grundlage für „entfallen".
4. **Die 24 Inline-Pfade bleiben unbewacht** — **strukturell eingetreten, wie vorab angesagt**: Kein
   Gate sieht Inline-Code-Pfade (`codepaths.roots` erreicht weder `.harness` noch `.claude`); das
   ist der Grund, warum die 6 offenen `AGENTS.md`/`close-welle.md`-Treffer aus §2 bis heute nicht
   aufgefallen sind. `slice-162` (Versions-Sensor) bleibt der benannte, noch nicht gebaute
   Systemfix. Tragfähige Grundlage für „weiter offen" → Beobachtungs-Register (Klasse bereits bei
   2×, Instanz-Zähler dieses Slice würde sie auf 3× heben).
5. **Vorab benannt: `slice-213`/`slice-214` vergleichen nach dem Tausch eine Datei mit sich
   selbst — ist es eingetreten?** **Ja, für `slice-213`, empirisch bestätigt:**
   ```sh
   diff -u .harness/baseline/v6.7.2/templates/docs/reviews/review-report.template.md \
           /Development/KI/ai-harness-course/lab/templates/docs/reviews/review-report.template.md
   # -> leer, EXIT 0
   ```
   Der Kurs-Klon steht heute bei `v6.7.2-2-gf37abb8` (zwei reine Doku-Commits nach dem Tag, keiner
   berührt Templates). Die Prämisse von `slice-213` — *„Die neue Fassung liegt heute nur im Lab des
   Kurses und ist nicht adoptiert"* — ist durch den Tausch dieses Slice **falsch geworden**: Die
   Vorlage ist jetzt Teil des vendored `v6.7.2`-Baums, der Diff ist leer, der Sensor, den
   `slice-213` bauen wollte, hat kein Ziel mehr im ursprünglichen Sinn. `slice-214` selbst enthält
   keinen direkten Baum-vs-Klon-Vergleich, hängt aber inhaltlich an `slice-213`s Prämisse (Tabellenform
   der Reports) — mittelbar betroffen, nicht durch eigenes Kommando bestätigt. **Das Register
   erreicht mit dieser Instanz seinen dritten Beleg** (`folge-slice-ueberlebt-baseline-sprung-mit-
   alter-pflicht` stand bei 3× bereits **vor** diesem Slice — der Plan sagt das selbst in §8; diese
   Messung ist eine weitere, konkrete Bestätigung derselben Klasse, keine neue Zählung.) Tragfähige
   Grundlage für den Lese-Schritt, der laut Plan „in diese Closure gehört": mindestens
   `slice-213` braucht eine Korrektur seiner Prämisse, bevor es das nächste Mal bearbeitet wird.

## 5. ADR-Konformität

- **`ADR-0044` Festlegung 1** (Prozedur der Ziel-Fassung `v6.7.2` regiert) — **erfüllt**: der Baum
  ist `v6.7.2`, nicht `v6.7.1`; kein Pin trägt je `v6.7.1`.
- **`ADR-0044` Festlegung 2** (Delta-Basis `v6.0.0`, unverändert durch Zielstand-Bewegung) —
  **korrekt umgesetzt in der Buchung**: beide offenen Nachweis-Felder (`v6.5.0`-Zeile und
  `v6.7.2`-Zeile) nennen `slice-224` — genau die von `ADR-0044` §Konsequenzen verlangte
  Doppel-Zuweisung.
- **`ADR-0044` Folgepflicht (Architect), im selben Commit eingelöst** (§Baseline trägt Setzung +
  Zeiger, ADR-Index bekommt die Zeile) — **erfüllt**: `38174544` bucht `Stand: v6.7.2` und den
  Zeiger auf `ADR-0044`; die ADR-Index-Zeile für `ADR-0044` und der Zusatz bei `ADR-0043` waren
  bereits vor diesem Slice gesetzt (Teil der ADR-Annahme selbst, außerhalb dieses Diffs — konsistent
  mit `ADR-0044` §Geschichte, die den Accept-Übergang auf denselben Tag, aber vor den Slice-Commits
  datiert).
- **`ADR-0044` Folgepflicht (Planner), fällig vor dem Vollzug** (zwei Slices schneiden: Baum-Tausch
  + Adaptions-Durchgang) — **zur Hälfte eingelöst**: `slice-223` ist der Baum-Tausch;
  `slice-224` existiert in `open/` als der Adaptions-Durchgang (Kennung stimmt mit beiden
  Nachweis-Feldern überein, s. o.).
- **`ADR-0031` Festlegung 2** (Form der Buchung) — **eingehalten**, s. DoD 3 oben. Offene, vom
  Reviewer bereits benannte Randfrage: `ADR-0031` selbst steht auf `Proposed` und wird an drei
  Stellen in `ADR-0044` als bindend zitiert — `ADR-0044` benennt das ausdrücklich als ungelöste,
  nicht in ihrem Geltungsbereich liegende Frage („zweite benannte Lücke"). Kein neuer Befund, nur
  bestätigt.
- **`MR-007`** (committet vendored, netzlos) — **erfüllt**: `make baseline-verify` liest den Baum
  netzlos und meldet OK, `make regelwerk-check` (Netz, kein Gate) bestätigt das Asset unabhängig.
- **`AGENTS.md` §3.4/§3.11** (eingefrorene Bäume unberührt) — **erfüllt**: `git diff --name-status
  e488119c^..HEAD -- docs/reviews/ docs/plan/planning/done/ docs/plan/carveouts/done/
  docs/plan/planning/observations/ docs/plan/adr/ harness/conventions/done/` liefert nur die
  **neue** Review-Report-Datei (Addition, kein Byte-Eingriff in ein eingefrorenes Artefakt).
- **`AGENTS.md` §3.8** (Commit-Zuschnitt je Eigentümer-Rolle) — **erfüllt**: `38174544` berührt
  ausschließlich Architect-Artefakte, `30508fc1` ausschließlich `.harness/skills/reviewer.md`
  (ADR-0028-Eigentum der Reviewer-Rolle), beide Messages nennen die Rolle.

## 6. Plan-vs-Code-Diff — beide Richtungen

**Was der Plan vorsah und der Code nicht liefert:** die Adress-Hälfte von DoD 3 (s. §2) — 6 echte
Lücken (`AGENTS.md`, `.claude/commands/close-welle.md`), die der Plan/DoD explizit als
Liefer-Gegenstand benennt.

**Was der Code liefert und §3 nicht explizit auflistet — geprüft gegen §1-Abgrenzung:**

| Zusätzliches Artefakt | Auslöser | Fällt es unter §1? |
|---|---|---|
| `.claude/rules/*.md`-Symlinks (5 Stück, zeigen jetzt auf `v6.7.2`) | Symlinks in den Regelwerk-Baum wurden mit dem Tag-Rename automatisch mitgezogen; nach dem Tausch zeigten sie sonst ins Leere | **Ja, zwingend** — §1 nennt „jede Adresse in einem lebenden Artefakt"; ein kaputter Symlink im Auto-Kontext (`MR-035`) ist die schärfste Form davon. Reviewer bestätigt `find . -xtype l` → 0 kaputte Links. |
| 5 `test/mutations/*.sh`-Fälle (219, 220, 224, 244, 248) | reine Pfad-Umschreibung `v6.5.0` → `v6.7.2` in den zitierten Vorlagenpfaden | **Ja** — notwendige Konsequenz des Tausches, damit die Mutationsfälle weiter auf existierende Pfade zeigen; keine inhaltliche Änderung der geprüften Eigenschaft (Reviewer negativbefund: „reine Pfad-Umschreibungen"). |
| `internal/archive/anwenden.go` + 2 Go-Test-Fixturen (`<NNN>` → `<Kennung>`) | `test/archiv-stub-vorlagen.bats` deckte auf, dass die neue Vorlage (`v6.7.2`) den Platzhalter umbenannt hat; ohne Nachzug wäre `make gates` rot geworden | **Ja, zwingend aus DoD „make gates grün"** — mechanische 1:1-Umbenennung, kein Wert- oder Logikwechsel. Reviewer hat die 1:1-Eigenschaft eigens nachgebaut und bestätigt (`diff` leer). |
| 2 Kommentare in `internal/emit/templates.go` | Tag-Nachzug in Code-Kommentaren, die den Baseline-Tag nennen | **Ja** — dieselbe Adress-Klasse wie §1, nur in `.go`-Dateien statt `.md`. |

**Urteil zum Diff:** Alle vier Zusätze sind **erzwungene, mechanische Konsequenzen** des
Baum-Tauschs — keiner erweitert den Liefergegenstand um einen vierten Punkt, keiner verletzt eine
der fünf §1-Ausschlussklassen. Das einzige echte **Fehlen** gegenüber dem Plan ist die bereits unter
§2/§3 benannte Adress-Lücke (`AGENTS.md`, `.claude/commands/close-welle.md`).

## 7. Was ich nicht geprüft habe

- **`make gates` als Ganzes, `make mutate`, `make smoke`, `make full-smoke`** — Anweisung; gestützt
  auf Diffsha-Stempel (gates) und die vom Reviewer real rot gesehenen Mutationsproben (Pin-Kopplung).
- **Ob die vier Commits `e488119c…38174544` als zusammenhängender Block gepusht wurden** (Risiko 2
  aus §6 des Plans) — git-lokal nicht beobachtbar, siehe §4 Punkt 2.
- **Das inhaltliche Delta von `v6.7.2`** (welche Regel welches Artefakt trifft) — ausdrücklich
  Gegenstand von `slice-224`/`slice-225`, nicht dieses Slice.
- **Die emittierte Inhalts-Ebene** (`internal/emit/templates/`) — eigener Prüfbereich, eigener Beleg
  (`make full-smoke`).
- **`slice-214`s eigene Prämisse im Detail** — ich habe nur bestätigt, dass es keinen direkten
  Baum-vs-Klon-Vergleich enthält und mittelbar von `slice-213` abhängt; eine vollständige
  Neu-Prüfung von `slice-214` selbst war nicht Gegenstand dieses Auftrags.
- **Kontext-Trennung zwischen den vier Läufen** — aus `git` nicht beobachtbar; Rollen-Labels und
  Commit-Zuschnitt stimmen (s. §5), das ist alles, was beobachtbar ist.

---

## Verdikt

**Nicht abschlussreif — ein DoD-Punkt ist offen, kein struktureller Defekt.**

- DoD 1, 2: **erfüllt**, mehrfach unabhängig belegt (Baum-Rename, fünf Pins, Asset-Provenienz,
  fail-closed-Kopplung rot gesehen).
- **DoD 3: nicht erfüllt.** Die drei §1-Kommandos liefern `0 · 0 · 12` statt der zugesagten `0`. 6
  der 12 Treffer (`harness/conventions/MR-054`, `MR-055`) sind durch eine sachlich richtige, aber im
  Plan nicht vorgesehene Architect-Deutung gedeckt (Tree-Operand-artige Historienzitate nach
  `MR-033`); die anderen 6 (`AGENTS.md` ×4, `.claude/commands/close-welle.md` ×2) sind **echte,
  vom Plan selbst benannte, nicht eingelöste Liefer-Pflicht** — der Reviewer hat das als MEDIUM-1/
  MEDIUM-2 notiert und dem Planner zwei Auflagen mitgegeben, statt zu blockieren. Aus
  Verifikations-Sicht ist das kein Ermessensspielraum: Der Wortlaut von DoD 3 verlangt `0`, der
  Ist-Stand ist `12`, und die Lücke ist im Plan selbst als Scope benannt (nicht durch §1
  ausgeschlossen).
- `make gates`: **durch Diffsha-Stempel gedeckt**, nicht neu gefahren.
- Review, Doku-Update (`harness/conventions.md`): **erfüllt**.
- Closure-Notiz, Beobachtungs-Register, Risiko-Ausgänge, drei Paarungen: **erwartungsgemäß offen**
  — `AGENTS.md` §3.10 bindet sie an den Planner-Kontext nach dieser Verifikation. Für keines der
  fünf Risiken aus §6 fehlt die Evidenz für eine Ausgangs-Zuweisung (§4); für Risiko 5 liegt eine
  **neue, konkrete Bestätigung** vor (`slice-213` vergleicht nach dem Tausch eine Vorlage mit sich
  selbst — leerer Diff, empirisch nachgemessen).

**ADR-Konformität:** `ADR-0044` Festlegungen 1/2 und die Architect-Folgepflicht erfüllt;
`ADR-0031` Festlegung 2 in der Buchungsform eingehalten (deren eigener `Proposed`-Status ist eine
bereits benannte, nicht hier zu lösende Randfrage). `MR-007`, `AGENTS.md` §3.4/§3.8/§3.11 gehalten.

**Empfehlung an den Planner:** Vor der Closure DoD 3 schließen — entweder (a) `AGENTS.md` und
`.claude/commands/close-welle.md` in einem weiteren, rollen-korrekten Commit nachziehen (Architect
bzw. die Rolle, die `close-welle.md` ausführt), oder (b) DoD 3 im Plan **vor** der Closure explizit
auf die verbliebenen 6 Fälle einschränken und deren Behandlung als benannte Slice-IDs delegieren
(wie es der Reviewer für MEDIUM-1 vorschlägt) — DoD **nachträglich in der Closure-Notiz** als
erfüllt umzudeuten, ohne eine der beiden Routen zu gehen, wäre die stille Zusagen-Erweiterung, die
`AGENTS.md` §3.6/§3.7 ausschließt. Beides ist Planner-Entscheidung, keine Verifikations-Frage.

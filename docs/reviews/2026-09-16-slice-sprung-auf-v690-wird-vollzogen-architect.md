# Architect-Verdikt: slice-sprung-auf-v690-wird-vollzogen gegen die ADR-Lage

**Rolle:** Architect (Modul 8, Übergabe Planner → Architect → Planner). **Datum:** 2026-09-16.
**Autor:** ai-harness-init-Team (pt9912).

**Gegenstand:** der Slice-Plan `slice-sprung-auf-v690-wird-vollzogen` am Stand `e8fb5248`
(`git show e8fb5248:docs/plan/planning/next/slice-sprung-auf-v690-wird-vollzogen.md | wc -l` → **657**);
der Mess-Slice `slice-stilllegungs-kanten-sind-gemessen` nur als Adresse des Ausschlusses in §1.
Zeilenangaben unten beziehen sich auf diesen Stand.

**Prüfgrundlage:** [ADR-0056](../plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md)
(`Accepted`, §Konsequenzen, Accept-Zeile der §Geschichte),
[ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegungen 1–4,
[ADR-0043](../plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 2,
[ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2
(`Proposed`), [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md),
[ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md),
[ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
[ADR-0048](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md),
[`harness/migration.md`](../../harness/migration.md) §4–§6, `MR-007`,
[`AGENTS.md`](../../AGENTS.md) §3.8 und §3.10.

**Nicht Gegenstand:** die zwei Setzungen des Auftraggebers (vollständige Übernahme, auch
bestehende `MR`-Abweichungen treten zurück; die bestehenden Instanzen trägt DoD 3.4).

`K` steht für einen Klon des Kurs-Repos. Ein Kommando über zwei Tags hat eine feste Zahl; eines über
dem Arbeitsbaum ist am Stand `e8fb5248` gemessen und **kein Erwartungswert**.

---

## 1. Verdikt

**ADR-Bezüge bestätigt. Für den Plan ist keine Folge-ADR nötig.** Vor dem Start ist **eine**
Norm-Frage zu entscheiden, die der Plan als Risiko 10 führt. Sie betrifft nicht die Anwendung von
ADR-0056, sondern die Eigentumsfrage an `docs/plan/planning/README.md` (§4, §6).

- **Der `Bezug:` trägt.** Die Folgepflichten aus ADR-0056 §Konsequenzen sind richtig auf die
  Liefer-Punkte verteilt: *Planner, vor dem Vollzug* → 1 und 3, *Architect, im Durchgang* → 2,
  *Architect, mit dem Tausch* → Voraussetzung für 3.4. Die Übernahme-Vorgabe ist so gelesen, wie
  ADR-0056 sie verbucht: *widerspricht* führt zum Rücktritt des Eintrags, *bewusst abweichend*
  entfällt im Instanz-Durchgang.
- **Der Schnitt „ein Slice" trägt, und die ADR verlangt ihn im Kern sogar.** ADR-0056 überlässt den
  Schnitt dem Planner. Ihre Accept-Zeile hält aber fest: *„die bestehenden Instanzen trägt die DoD
  des Slice, der den Tausch vollzieht"*. Ein getrennter Instanz-Slice widerspräche diesem Satz.
  Grund 2 des Plans stimmt mit ADR-0018 Festlegung 2 und ADR-0056 §Der Unterschied überein: Die
  Klassen-Aussagen sind Ist-Maßstab und werden mit dem Tausch fällig.
- **Kein Re-Evaluierungs-Trigger von ADR-0056 feuert durch den Plan.** Trigger 3 feuert, wenn der
  Report eine Einordnung zeigt, *„die allein der Prozedur-Text von `v6.9.0` verlangt"*. Liefer-Punkt
  3.4 ordnet sich selbst als Ist-Maßstab ein (Z. 358–360), nicht als Prozedur-Schritt. **Auflage an
  den Vorlagen-Bericht:** Sein Abschnitt zu den bestehenden Instanzen trägt dieselbe Einordnung.
  Sonst sieht der Report so aus, als löse er Trigger 3 aus.

Befunde am Plan, jeder mit Adressat Planner:

| # | Stufe | Stelle | Befund |
|---|---|---|---|
| B1 | MEDIUM | Z. 309–320, 432–435, 460–461, 509–514, 645–647 | Die Prämisse zum Koexistenz-Satz ist falsch (§2). Suchhilfe 3, der zweite Punkt der Reihenfolge in §3, das Beispiel in Rückführung (a), Risiko 3 und ein Teil des Evidenz-Risikos in §8 hängen daran. |
| B2 | MEDIUM | Z. 541–544 | Risiko 10 nennt ADR-0048 nicht. Die ADR schließt die Planungs-README ausdrücklich aus, und ihr zweiter Re-Evaluierungs-Trigger feuert mit genau dieser Frage (§4). Außerdem weicht die Instanz schon von `v6.8.0` in zwei Zeilen ab, nicht nur in der `done/`-Zeile. |
| B3 | LOW | Z. 51–52 | ADR-0024 benennt nur den ADR-Index als Register. Für `harness/migration.md` §4–§6 liefert ihre Ableitung keine Rolle (§3). Quelle für die Zuordnung in diesem Sprung ist ADR-0056 §Kopplung und die Folgepflicht *mit dem Tausch*. |
| B4 | LOW | Z. 386–389 | Die DoD-Zeile leitet die Register-Zuordnung „aus dem Übergabe-Artefakt von Liefer-Punkt 2" ab. Die Zuordnung ist aber eine eigene Folgepflicht des Architect und liegt vor 3.4 (so Z. 436). Das Übergabe-Artefakt von Liefer-Punkt 2 enthält sie nicht. |
| B5 | INFO | Z. 590–591 | Der Satz, `git status -sb` melde keinen Vorlauf, stimmt am geprüften Stand nicht (`git status -sb` → `## main...origin/main [voraus 6]` bei `e8fb5248`). Außerdem ist er eine Momentaufnahme (§5, Punkt 20). |

## 2. Frage 2 — der Koexistenz-Satz und `make vendor-baseline`

**Es gibt keinen neuen Widerspruch, und vor dem Start ist nichts zu entscheiden.** Der Satz ist
kein Teil des Deltas. Er ist eine Abweichung, die `MR-007` seit Langem deklariert, und die Sperre
im Werkzeug setzt genau diese Abweichung durch.

**Der Satz liegt außerhalb des Hunks und ist nicht neu:**

```sh
git -C "$K" diff -U0 v6.8.0..v6.9.0 -- lab/regelwerk/modul-02-harness-bootstrap.md | grep '^@@'
# -> @@ -279,9 +279,27 @@            (der einzige Hunk beginnt bei Zeile 279)
git -C "$K" show v6.9.0:lab/regelwerk/modul-02-harness-bootstrap.md | grep -n 'Das alte Verzeichnis fällt'
# -> 268:
git show e8fb5248:.harness/baseline/v6.8.0/regelwerk/modul-02-harness-bootstrap.md | grep -n 'Das alte Verzeichnis fällt'
# -> 268:                               (vendored, adoptierter Stand v6.8.0)
for t in v5.12.0 v5.18.0 v6.0.0 v6.5.0 v6.7.2; do git -C "$K" show $t:lab/regelwerk/modul-02-harness-bootstrap.md | grep -c 'Das alte Verzeichnis fällt'; done
# -> 1 1 1 1 1
```

Der Satz steht in demselben Punkt (*„Der Review vergleicht auch die Form"*) wie der Hunk, aber in
Zeile 268 und damit vor ihm. Er gehört zu allen adoptierten Ständen seit `v5.12.0`. Der Hunk fügt
Klassen-Aussagen zu Append-only hinzu, und keine davon betrifft die Frage, ob alte und neue
Verzeichnisse nebeneinander liegen.

**`MR-007` ersetzt genau diesen Satz, und zwar wörtlich.** Das Feld `Ersetzt-Baseline-Regel` von
`MR-007` zitiert ihn vollständig (*„Weil der Vendoring-Pfad `<tag>`-gescopt ist, liegen alte und
neue Form nebeneinander: … Das alte Verzeichnis fällt erst, wenn der Review durch ist."*). Es setzt
Setzung 4 an seine Stelle: *„ein Tag zur Zeit, Historie in `git` … Die alte Form bleibt damit
erreichbar, aber als Tree-Operand statt als zweites Verzeichnis"*
(`grep -c 'als Tree-Operand statt als zweites Verzeichnis' harness/conventions/MR-007-*.md` → **1**).
Laut Feld ist die Abweichung gemessen am adoptierten Stand `v5.12.0`.

**Was das Werkzeug tut, stimmt mit dieser Abweichung überein:**

- Das `Makefile`-Rezept ruft den Träger mit `BASELINE_TAG` und `BASELINE_ZIP_SHA256` auf
  (`grep -n -A1 '^vendor-baseline:' Makefile`).
- Der Träger bricht ab, wenn ein anderer Tag vorliegt, und nennt dabei `MR-007` Setzung 4
  (`grep -n 'ein Tag zur Zeit' cmd/ai-harness-init/vendor_baseline.go` → Zeilen 50 und 92).
- [`harness/sensors/vendor-baseline.md`](../../harness/sensors/vendor-baseline.md) führt dieselbe
  Sperre unter §Sperren und §Grenze.
- `harness/tools/baseline-verify.sh` meldet mehr als ein `<tag>`-Verzeichnis als Fehler
  (`grep -n 'mehr als ein <tag>-Verzeichnis' harness/tools/baseline-verify.sh`).

**Urteil:**

- **Kein Ausgang *widerspricht* aus diesem Sprung.** Der Adaptions-Durchgang fragt, ob die neue
  Fassung das regelt, wofür der Eintrag angelegt wurde. Am Koexistenz-Satz hat sich nichts
  geändert. Den Ausgang für `MR-007` schreibt Liefer-Punkt 2 wie für jeden anderen Eintrag. Die
  Messung liefert dafür aber keine Grundlage im Delta.
- **Die Übernahme-Vorgabe ändert daran nichts, so wie ADR-0056 sie verbucht.** Sie greift bei den
  Ergebnissen des Durchgangs (*„Welche Einträge das betrifft, klärt der Durchgang"*), nicht bei
  jeder Abweichung, die schon vor dem Delta bestand.
- **Liefer-Punkt 3.2 folgt bereits der Ersatzform aus `MR-007`.** Er vergleicht die Form über das
  Commit-Paar des Tauschs, also als Tree-Operand. Die Frage aus Z. 434–435, ob das den Satz
  „erfüllt", beantwortet `MR-007`: Der Satz ist ersetzt, der Tree-Operand ist die Ersatzform.
- **Folge für den Plan (B1):** Risiko 3 hat keinen Gegenstand in diesem Sprung. Suchhilfe 3
  schrumpft auf einen Zeiger auf `MR-007`. Das Beispiel in Rückführung (a) entfällt.

**Einzige Bedingung, unter der das anders wäre:** Der Auftraggeber meint mit „auch bestehende
`MR`-Abweichungen treten zurück" auch Abweichungen, deren Baseline-Text das Delta nicht berührt.
Das ginge über die Verbuchung in ADR-0056 hinaus (§6, Punkt 2).

## 3. Frage 3 — Register-Zuordnung von `gate`, `welle-results` und `MR-NNN-titel`

**Die Zuordnung kann im Lauf des Slice fallen, und zwar im Architect-Kontext nach dem
Tausch-Commit und vor Liefer-Punkt 3.4. Eine Norm-Entscheidung braucht sie nicht.**

- **Wann:** ADR-0056 §Konsequenzen legt Rolle und Moment fest: *„Folgepflicht (Architect), mit dem
  Tausch: die Register-Zeilen in `harness/migration.md` §4 bis §6 gegen die Klassen-Aussagen von
  `v6.9.0` prüfen"*. Vorher ist `v6.8.0` der Ist-Maßstab (ADR-0018 Festlegung 2). Die Zuordnung
  vorzuziehen hieße, einen Maßstab anzuwenden, der noch nicht gilt.
- **Warum keine Norm:** [`harness/migration.md`](../../harness/migration.md) §4 bezeichnet seine
  Zuordnung als *„Beobachtung am Bestand, keine ADR-Aussage"*. Die Ziel-Fassung ordnet alle drei
  Vorlagen selbst und wörtlich ein, der Architect liest also nur ab (`v6.9.0` ·
  `lab/regelwerk/modul-02-harness-bootstrap.md`, einziger Hunk, siehe `git -C "$K" diff
  v6.8.0..v6.9.0 -- lab/regelwerk/modul-02-harness-bootstrap.md`):

  | Register-Zeile | Wortlaut `v6.9.0` | Zuordnung |
  |---|---|---|
  | `welle-results` | *„Welle `welle.template.md`, `welle-results.template.md` **und** `archiv-stub-welle.template.md` … gilt die Append-only-Logik für **jede** von ihnen"* | Buchstabe b |
  | `MR-NNN-titel` | *„`MR`-Einträge (`harness/conventions/MR-NNN-titel.template.md`) gehören ebenfalls dazu"* | Buchstabe b |
  | `gate` | *„**Sensor-Gate-Dateien (`harness/sensors/gate.template.md`) dagegen nicht**"* | Buchstabe a |
  | `observation` | nicht genannt | bleibt in §6 offen |

  Die Form des Belegs ist Tag plus Zitat. Mit dem Tausch sind beide netzlos im vendored Baum
  prüfbar.
- **Wer schreibt:** der Architect. Die tragende Quelle ist ADR-0056, nicht ADR-0024 allein (B3).
  ADR-0024 Festlegung 1 leitet die Rolle aus den Originalen ab. Das trägt §1–§3 von
  `harness/migration.md`, denn dort werden ADRs projiziert. Die Originale von §4–§6 sind dagegen
  vendored Vorlagen und Instanzen, die verschiedene Rollen schreiben. Dafür lässt ADR-0024
  Festlegung 2 die Frage offen. ADR-0056 §Kopplung (*„Beide Dateien gehören dem Architect"*) und
  ihre Folgepflicht schließen die Lücke für diesen Sprung.
- **Commit-Zuschnitt:** eigener Architect-Commit nach [`AGENTS.md`](../../AGENTS.md) §3.8. Er muss
  nicht in denselben Push wie der Tausch, damit die Gates grün bleiben:
  `grep -oE '\]\([^)]*\.harness/baseline/v6\.8\.0[^)]*\)' harness/migration.md | wc -l` → **0**.
  Die tag-tragenden Pfade dort sind Inline-Code, das Doku-Gate sieht sie also nicht.

**Hinweis für Liefer-Punkt 3.4, an der Zeile `gate`:** Unter Buchstabe a fehlt das Ventil
*bewusst abweichend* (Risiko 4). Die Abschnitts-Überschriften zeigen, wie groß das Risiko ist:

```sh
T=$(git show e8fb5248:.harness/baseline/v6.8.0/templates/harness/sensors/gate.template.md | grep '^## ')
for f in harness/sensors/*.md; do grep '^## ' "$f" | grep -vxF -f <(printf '%s\n' "$T") | sed "s|^|${f##*/}: |"; done
# -> full-smoke.md: ## Deklaration der Stufen
#    history-range-guard.md: ## Im gebootstrappten Ziel
#    slice-mv.md: ## Im gebootstrappten Ziel
ls harness/sensors/*.md | wc -l      # -> 15
```

Drei von 15 Dateien haben Abschnitte, die die Vorlage nicht kennt. Die Inhaltsregel der Vorlage
(*„Was hier NICHT steht: womit das Werkzeug selbst gedeckt ist"*) prüft der Überschriften-Vergleich
nicht. `gate.template.md` hat kein Delta zwischen den Tags, gemessen wird also die bestehende Form.
Rückführung (b) ist hier eine realistische Möglichkeit, nicht nur eine theoretische.

## 4. Frage 4 — wer schreibt `docs/plan/planning/README.md`

**Die Frage ist offen. Keine Quelle benennt die Rolle, und eine Accepted-ADR nimmt die Datei
ausdrücklich aus.**

- **[`AGENTS.md`](../../AGENTS.md) §3.8** bindet die Hard Rules, den Adaptions-Block, über
  ADR-0024 den ADR-Index und über ADR-0028 den Anweisungssatz. Zu weiteren Norm-Artefakten sagt der
  Abschnitt: *„wo keine sie benennt, bleibt die Frage offen"*.
- **§3.10** bindet den Abschluss eines Slice samt einem berührten Welle-Plan. Die Planungs-README
  gehört nicht dazu.
- **ADR-0024** betrifft derivative Register. Die Planungs-README gibt keine Zeilen eines Originals
  wieder, das eine Rolle dieses Repos schreibt. Ihre Lifecycle-Tabelle projiziert die vendored
  Vorlage und `modul-05`, also keinen Repo-Autor.
- **ADR-0028** betrifft Anweisungssätze **einer** Rolle. Die README liest jede Rolle, sie ist
  keiner zugeordnet.
- **ADR-0015** Festlegung 1 trifft ausdrücklich *„keine Eigentums-Aussage über irgendein drittes
  Artefakt"*.
- **ADR-0048** (`Accepted`) entscheidet nur über den Welle-Plan. Zur Planungs-README hält sie fest:
  *„Diese Entscheidung deckt die Datei **nicht** … und sie weist sie auch niemandem zu."* Ihr
  zweiter Re-Evaluierungs-Trigger lautet: *„Wenn dieselbe Frage für ein zweites
  Planungs-Artefakt entschieden werden muss (beobachtbar an einem Vorgang, der eine
  Eigentums-Frage an Roadmap, Slice-Plan oder `docs/plan/planning/README.md` stellt): Dann ist zu
  prüfen, ob die Verengung auf den Welle-Plan noch trägt oder ob Option E … die billigere Antwort
  ist."* **Mit Risiko 10 ist dieser Trigger eingetreten.** Ihn zu prüfen ist Architect-Arbeit, und
  das Ergebnis ist eine neue ADR, denn ADR-0048 ist immutabel.

**Der Umfang ist größer, als Risiko 10 angibt (B2).** Die Instanz weicht schon von der Vorlage
`v6.8.0` ab, und zwar in zwei weiteren Zeilen:

```sh
diff <(git show e8fb5248:.harness/baseline/v6.8.0/templates/docs/plan/planning/README.template.md | sed -n '/^| Verzeichnis/,/^$/p') \
     <(sed -n '/^| Verzeichnis/,/^$/p' docs/plan/planning/README.md)
# -> 4,5c4,5   (Zeilen next/ und in-progress/; die done/-Zeile ist gleich)
```

Daraus folgt: *schon erfüllt* steht für diese Instanz nicht zur Verfügung. *Übernommen* bedeutet
bei vollständiger Übernahme drei Zeilen, nicht nur eine. Die Zeile zu `in-progress/` in der Instanz
(„Branch / PR existiert.") widerspricht zudem `v6.8.0` · `modul-05-planning-harness.md`
§Lifecycle als State Machine (*„der Branch entsteht danach"*).

**Empfehlung, nicht in diesem Lauf geschrieben:** Die Entscheidung fällt vor dem Start als
Architect-ADR, ausgelöst durch den zweiten Trigger von ADR-0048. Die günstigste Variante liegt in
ADR-0048 schon als Option E vor: Festlegung 1 (vorlagengebundener Nachzug) gilt dann für alle
lebenden Planungs-Artefakte. Die drei Tabellenzeilen wären byte-gleiche Wiedergaben der Vorlage und
dürften damit im Implementations-Kontext geschrieben werden, soweit die übrigen Bedingungen der
Probe halten. Ohne eine solche Entscheidung kann Liefer-Punkt 3.3 für die README nur als
Übergabe-Artefakt enden, und der Slice wartet.

**Randbefund zur Roadmap-Instanz:** Das Delta der Roadmap-Vorlage steht in einem HTML-Kommentar,
den die Instanz nicht übernommen hat
(`grep -c 'NUR Umplanungen' docs/plan/planning/in-progress/roadmap.md` → **0**). Die Regel steht dort
in Prosa unter §Historische Trigger-Verschiebungen
(`grep -n 'Regeln dieser Sektion' docs/plan/planning/in-progress/roadmap.md`). *Übernommen* heißt
also, diese Prosa zu ergänzen. Das ist ein Planner-Commit, so wie der Plan es vorsieht.

## 5. Kürzungsliste

Die Beobachtung `slice-plan-umfang-waechst-ueber-umsetzung-hinaus` steht auf `geplant`
(`head -1 docs/plan/planning/observations/BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus/state.md`)
und hat drei Belege
(`ls docs/plan/planning/observations/BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus/evidence/*.md | wc -l`
→ **3**).

**22 Stellen, zusammen etwa 150 von 657 Zeilen.** Die Zeilenzahlen sind am Stand `e8fb5248`
geschätzt. Gekürzt wird hier nichts, das tut der Planner.

**Ausgenommen:** Text aus der vendored Slice-Vorlage (*„Regeln dieser Sektion"*, Z. 196–205,
577–580, 623–626; `git show e8fb5248:.harness/baseline/v6.8.0/templates/docs/plan/planning/slice.template.md | grep -n 'Keine Mindestzahl'`
→ Zeilen 42 und 59). Ob er bleibt, entscheidet `slice-plan-umfang-bleibt-beim-gegenstand`, nicht
dieser Plan.

| # | Stelle | Umfang | Warum sie für die Umsetzung nicht trägt |
|---|---|---|---|
| 1 | Z. 18–22, Absatz *Ebene* | ~5 | wiederholt den Ausschluss *Kein Inhalt der emittierten Ebene* (Z. 182–184); eine der beiden Stellen genügt |
| 2 | Z. 29–60, `Bezug:` | ~12 | die Klammern wiederholen Inhalte von ADR-0056 und ADR-0018 (Folgepflicht-Zuordnung, Festlegungs-Inhalte); der Bezug braucht die Kennung und höchstens einen Halbsatz |
| 3 | Z. 102–111, Gründe 2 (zweite Hälfte) und 3 | ~10 | der Vergleich mit dem Vorgänger und die Größenregel stehen schon in §2 und in §4 |
| 4 | Z. 133, 135–137 und 144–147 | ~7 | Dateizahlen, Nicht-Markdown-Zahl und `migration.md`-Zahl beeinflussen keine DoD; DoD 1.4 und 1.5 messen die Treffer, DoD 1.2 nennt die Pin-Dateien selbst |
| 5 | Z. 158–166 und 189–191 | ~6 | drei Ausschlüsse, die ADR-0056 §Was diese Festlegung nicht tut und §Fitness Function wiederholen; je ein Satz mit Zeiger genügt |
| 6 | Z. 192–194 | ~3 | doppelt zu Rückführung (a) in §4 |
| 7 | Z. 232–236 | ~3 | Begründung, warum der Plan keinen sha256 nennt; die Anforderung „am Asset gemessen, neben dem Kommando" reicht |
| 8 | Z. 277–289 | ~8 | wiederholt die Übernahme-Vorgabe und die Rückbau-Regel aus ADR-0056 und ADR-0018 Festlegung 4 |
| 9 | Z. 293–301, Suchhilfe 1 | ~9 | die Liste mit 20 Einträgen ist ausdrücklich kein Erwartungswert, und der Durchgang geht ohnehin alle 56 Einträge durch |
| 10 | Z. 303–307, Suchhilfe 2 | ~5 | doppelt zum Ausschluss Z. 176–181 und zu ADR-0056 §Außerhalb der Prozedur |
| 11 | Z. 309–320, Suchhilfe 3 | ~10 | falsche Prämisse (B1); ein Satz mit Zeiger auf `MR-007` `Ersetzt-Baseline-Regel` ersetzt sie |
| 12 | Z. 322–328 | ~4 | beschreibt die Stichprobe noch einmal, die der zitierte Abschnitt der Prozedur schon regelt |
| 13 | Z. 349–351 | ~3 | wiederholt die Messung aus ADR-0056; die Pflicht, vendored zu messen, steht in Z. 347–348 |
| 14 | Z. 368–373 | ~5 | Instanzzahlen, die keine Erwartungswerte sind und in keine DoD eingehen; der Lauf zählt ohnehin |
| 15 | Z. 432–435 | ~2 | falsche Prämisse (B1); es bleibt „der abgelöste Baum weicht vor dem Vendoring (`MR-007` Setzung 4)" |
| 16 | Z. 447–451 | ~4 | Momentaufnahme „am Datum dieses Plans erfüllt"; die Start-Bedingung wird beim Start geprüft |
| 17 | Z. 460–461 und 509–514 | ~7 | Beispiel in Rückführung (a) und Risiko 3 beruhen auf falscher Prämisse (B1); das Risiko hat in diesem Sprung keinen Gegenstand |
| 18 | Z. 519–531, Risiken 5 und 7, Risiko 6 zum Teil | ~13 | dauerhafte Werkzeug- und ADR-Eigenschaften, die an anderer Stelle stehen (ADR-0056 §Fitness Function, §Adoptierte Konventions-Quellen, ADR-0044); der einzige slice-eigene Teil von Risiko 6 (Hand-Kopie) ist durch DoD 1.1 ausgeschlossen; jedes gestrichene Risiko spart einen Ausgang bei der Closure |
| 19 | Z. 537–538 | ~2 | die Zahlen 66 und 23 beeinflussen nichts; der Ausschluss Z. 185–188 trägt das Risiko schon |
| 20 | Z. 590–592 | ~3 | Momentaufnahme mit `git status`, am geprüften Stand falsch (B5); die Zahl 121 geht in nichts ein |
| 21 | Z. 628–649, Modus-Block | ~20 | bei reinem GF genügt laut Vorlage der Hinweis; der Inhalt zum Evidenz-Risiko wiederholt §6 |
| 22 | Z. 651–657, *Zur Bemessung dieses Slice* | ~7 | Meta-Aussage über den Plan selbst, nicht über seinen Gegenstand |

## 6. Vor dem Start zu entscheiden

1. **Eigentum an `docs/plan/planning/README.md`** (Risiko 10; B2; §4). Das braucht eine
   Norm-Entscheidung: eine Architect-ADR, ausgelöst durch den zweiten Re-Evaluierungs-Trigger von
   ADR-0048, zwischen Option E und einer Einzelregelung für die README. Sie wird in diesem Lauf
   nicht geschrieben. Der Auftraggeber entscheidet, ob sie vor dem Start entsteht. Ohne sie bleibt
   Liefer-Punkt 3.3 für die README ein Übergabe-Artefakt, und der Slice wartet.
2. **Nur als Rückfrage, und nur falls die Setzung weiter reicht als ADR-0056 sie verbucht:**
   Sollen auch `MR`-Abweichungen zurücktreten, deren Baseline-Text das Delta nicht berührt? Dazu
   gehört etwa `MR-007` Setzung 4, die das Nebeneinander zweier Tag-Verzeichnisse verbietet. Dann
   bräuchte es eine Folge-ADR zu ADR-0056 und eine Änderung an `make vendor-baseline`,
   `harness/tools/baseline-verify.sh` und dem Injektor, bevor Liefer-Punkt 1 läuft. Ist die
   Setzung so gemeint, wie ADR-0056 sie verbucht, entfällt der Punkt.

Außerdem soll der Planner B1 und B2 am Plan nachziehen, bevor der Slice nach `in-progress/` geht.
Das ist keine Norm-Entscheidung.

## 7. Gate-Lauf

Nach dem Schreiben dieses Reports: `make docs-check`, dann `make gates`. Die Ergebnisse stehen in
der Übergabe an den Planner, nicht in diesem Report.

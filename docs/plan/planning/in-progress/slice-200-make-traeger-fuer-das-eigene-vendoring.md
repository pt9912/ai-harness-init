# Slice slice-200: Das eigene Vendoring bekommt seinen `make`-Träger — aus dem Asset, nicht aus dem `git`-Baum

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Ein neues `make`-Ziel mit eigenem Liefer-Wert; sein Beleg ist der Lauf des
Ziels selbst, und der steht in seiner eigenen DoD (Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (ein Vorgang, der von
Hand aus einem fremden Arbeitsbaum kopiert, ist nicht reproduzierbar — der Träger ist die Antwort),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (der Host bringt
`git`, `docker`, GNU `make` — ein Vendoring-Weg, der mehr verlangt, bricht die Zusage),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (dasselbe Asset
wandert per `internal/fetch` ins Ziel-Repo; die Fähigkeit ist da, nur nicht für den Dogfood-Baum),
[`ADR-0003`](../../adr/0003-go-native-binaries.md) (die Fähigkeit liegt in Go, der Träger gehört
ins `make`-Ziel),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(der vendored Baum ist committet, netzlos und genau ein Tag — Setzung 4 begrenzt, was der Träger
tun darf)

**Berührte Spec-Stellen:** `—` als Aussage. Der Slice legt einen Träger für eine bestehende
Fähigkeit; er ändert keine Festlegung des Technik-Stratums. Berührt er beim Bauen
[`spec/spezifikation.md`](../../../../spec/spezifikation.md), ist das ein Nachzug der
Gate-Beschreibung und in §3 zu führen.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-07.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Ein `make`-Ziel legt den vendored Baum dieses Repos **aus dem verifizierten
Release-Asset** an — Asset laden, `sha256` gegen `BASELINE_ZIP_SHA256` prüfen, die zwei Bäume
entpacken, `SHA256SUMS` schreiben —, sodass ein Baum-Tausch nicht mehr von Hand aus einem fremden
Arbeitsbaum kopiert wird.

**Die Fähigkeit ist da, der Träger fehlt.** `internal/fetch/baseline.go` kann genau diesen Weg
(`grep -nE '^func (DownloadBaseline|Baseline|unpackTrees|writeSums)' internal/fetch/baseline.go`),
und `fetch.Baseline` hat **einen** Aufrufer — den Init-Pfad für Zielrepos
(`git grep -n 'fetch\.Baseline(' -- cmd internal | grep -v _test` → eine Zeile in
`cmd/ai-harness-init/main.go`). Für den eigenen Baum gibt es kein `make`-Ziel
(`grep -nE '^(baseline|regelwerk)[a-z-]*:' Makefile` nennt `baseline-verify`,
`baseline-freshness` und `regelwerk-check` — drei prüfende, kein herstellendes). **Ohne Träger
entsteht der Fehler beim nächsten Sprung wieder**, und er ist nicht hypothetisch: Der Baum kam beim
Sprung auf `v6.5.0` zunächst aus dem `git`-Baum des Kurs-Klons statt aus dem Asset.

**Warum das nicht `make baseline-verify` erledigt.** Das Ziel hält den Baum gegen `SHA256SUMS`, und
`SHA256SUMS` ist selbst erzeugt — es trägt die lokale Integrität, **nicht die Herkunft**
(`harness/tools/baseline-verify.sh` §Kopfkommentar). Genau diese Hälfte der Provenienz-Kette
benennt [`harness/conventions.md`](../../../../harness/conventions.md) §Adoptierte
Konventions-Quellen als unbewacht: *„Asset → vendored Baum hält nichts"*. Sie hängt am
Vendoring-**Vorgang**, und dieser Slice gibt ihm einen.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Ein Gate daraus machen.** Das Ziel **stellt her**, es prüft nicht; ein Gate darüber wäre eines,
  das Netz braucht und `make gates` netzlos-brechen würde — dieselbe Begründung, mit der
  `regelwerk-check` und `baseline-freshness` außerhalb von `make gates` stehen
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Den Pin-Nachzug mitnehmen.** Die fünf Pin-Stellen sind fail-closed aneinander gekoppelt und
  laufen in `make gates`; sie zu bewegen ist der Tausch-Vorgang, nicht sein Werkzeug. Wer beides
  zusammenlegt, bekommt ein Ziel, das nicht wiederholbar ist, weil es beim zweiten Lauf gegen
  bereits gezogene Pins läuft.
- **Die Adress-Nachzugs-Hälfte des Tauschs.** Sie ist mechanisch anders geartet (Text statt Bytes)
  und hat mit `make slice-mv` und `make archive-welle` bereits Nachbarn; sie hier anzuhängen machte
  aus einem Vendoring-Ziel ein Tausch-Skript.
- **Die Koexistenz zweier Tags.** `make baseline-verify` bricht fail-closed bei zwei
  `<tag>`-Verzeichnissen ab
  ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  Setzung 4). Das Ziel **ersetzt** darum, es legt nicht daneben — und ob diese Setzung richtig ist,
  entscheidet es nicht.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [x] **Ein `make`-Ziel legt den vendored Baum aus dem verifizierten Asset an**, gefahren über den
      Träger aus [`ADR-0003`](../../adr/0003-go-native-binaries.md) — kein Host-Werkzeug in der
      Befehlsposition ([`AGENTS.md`](../../../../AGENTS.md) §3.9). Es liest den Tag und den
      `sha256` aus den **kanonischen** Makefile-Variablen `BASELINE_TAG`/`BASELINE_ZIP_SHA256`
      (`grep -nE '^BASELINE_(TAG|ZIP_SHA256)' Makefile`), nicht aus einem zweiten Wert, und bricht
      bei Abweichung ab, statt zu schreiben. Nach dem Lauf meldet `make baseline-verify` `OK` und
      `ls -d .harness/baseline/v*/ | wc -l` gibt `1`. Beide Prüf-Rollen haben den Lauf einzeln
      nachgefahren; die Verifikation nennt Rezept, Argumente und beide Nachher-Werte.
- [x] **Der Lauf ist über denselben Tag wiederholbar und liefert byte-gleiche Bäume** —
      [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), gemessen als
      Fingerabdruck des Baums vor und nach einem zweiten Lauf, nicht zugesagt. **Und ein Lauf mit
      falschem `sha256` färbt rot:** Das ist das rot zu sehende Gegenbeispiel
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6) — ohne es ist nicht belegt, dass die Prüfung
      überhaupt greift, sondern nur, dass der Happy Path läuft. Der Lauf-Bericht nennt die gelesene
      Fehlermeldung; ein Abbruch lässt den vorhandenen Baum **unverändert**. Beide Hälften sind
      unabhängig zweimal gefahren — derselbe Baum-Fingerabdruck vor und nach dem Lauf, und die
      gelesene `SHA256Mismatch`-Meldung am Produkt-Binär **und** über das `make`-Ziel.
- [x] `make gates` grün. In dieser Closure über dem Baum gefahren, der sie trägt: EXIT 0.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8). Der Review-Report vom
      2026-09-08 (2 HIGH / 1 MEDIUM / 2 LOW / 3 INFO, Verdikt *blockiert*) und der
      Verifikations-Report desselben Tages liegen vor; beide HIGH und das MEDIUM sind behoben, kein
      Befund blockiert die Closure.
- [x] Doku-Update für <Schnittstelle X> falls öffentlicher Vertrag berührt. Berührt ist das neue
      `make`-Ziel selbst; seine Beschreibung liegt im `Makefile`-Kopfkommentar und in
      [`harness/README.md`](../../../../harness/README.md). **`AGENTS.md` §4 bleibt unberührt** —
      dazu §7, zweiter Lerneintrag.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register fortgeschrieben, **falls dieser Slice einen Inventur-Fund auflöst** —
      Zeile mit Datum und auflösendem Artefakt nach *Aufgelöste Einträge* verschoben. **Entfällt
      hier:** Repos ohne Brownfield-Bootstrap haben die Datei nicht, und dieses führt sie nicht
      (`ls docs/plan/planning/reconciliation.md` → nicht vorhanden). Der Pfad steht als
      **Kommando-Operand**, weil die vendored Vorlage ihn als blanken Inline-Code führt und
      `codepaths` ihn dann als fehlendes Ziel meldet — dieselbe Stelle, die
      [slice-193](../done/slice-193-baum-tausch-v650-pins-ziehen.md) §6 als offenen Punkt
      führt.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert. Sechs Belege, drei neue Einträge — §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen). Vier von vier, je genau einer.
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit). **Dieses Repo führt Wellen-Betrieb; der Träger ist benannt, und die Messung liegt ihm vor** — §7, letzter Punkt.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` (neues Ziel) | neu | der Träger; er ruft den Produkt-Träger, keine Host-Toolchain |
| `cmd/ai-harness-init/main.go` (Dispatch) | update | die Fähigkeit braucht einen Einstieg für den **eigenen** Baum; heute erreicht sie nur der Init-Pfad |
| `internal/fetch/baseline.go` | vermutlich unberührt | die Fähigkeit ist vollständig; ändert sie sich doch, ist das ein Befund und gehört in die Closure-Notiz |
| [`harness/README.md`](../../../../harness/README.md), [`AGENTS.md`](../../../../AGENTS.md) §4 | update | ein neues Ziel bekommt seine Beschreibung; **wo** sie steht, entscheidet die Sensors-Regel der Ziel-Fassung (§6) |

**Wenn der Einstieg ein Unterkommando wird, gilt die Kopplung.** `test/unterkommando-kopplung.bats`
hält jeden Namen, den ein Aufrufer dieses Repos hinter dem Träger nennt, gegen die `case`-Marken des
Dispatch — ein neuer Name ohne `case` färbt rot, und das ist gewollt.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **`make gates` ist grün** — beobachtbar am Lauf selbst. Der
Slice fasst `Makefile`, `cmd/` und Gate-Beschreibungen an; auf rotem Baum ist nicht unterscheidbar,
ob sein eigener Stand rot färbt oder der geerbte. Diese Bedingung ist am Tag dieses Plans
**unerfüllt** (36 Befunde, `make docs-check`), und das ist die gewollte Wirkung: Der Slice wartet
auf [slice-197](../done/slice-197-eingefrorene-baseline-adresse-bekommt-ihr-ventil.md).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der Einstieg mehr verlangt als eine
  Verdrahtung — etwa weil `fetch.Baseline` für den eigenen Baum eine andere Ersetzungs-Semantik
  braucht als für ein frisches Zielrepo (`replaceBaseline` gegen `placeBaseline`). Dann sind
  Einstieg und Semantik zwei Slices.
- `in-progress` → `open` (blockiert — Carveout?): wenn das Ziel nur mit Netz lauffähig ist und
  damit in keiner Umgebung reproduzierbar geprüft werden kann, die dieses Repo führt. Netz ist für
  ein herstellendes Ziel legitim (`regelwerk-check` fährt so), **ein ungeprüftes Ziel ist es
  nicht** — dann ist der rote Status auf einen Trigger zu schalten statt still zu übergehen.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. Das Ziel läuft über dem heute gepinnten Tag, `make baseline-verify` meldet danach `OK`, und der
   Baum ist byte-gleich zu dem, der vor dem Lauf lag — der Nachweis, dass der Träger den Bestand
   **reproduziert** statt ihn zu ersetzen.
2. Das Gegenbeispiel mit falschem `sha256` ist **rot gesehen**, und der Lauf-Bericht nennt die
   gelesene Fehlermeldung samt dem Nachweis, dass der Baum unverändert blieb.

**Lerneintrag** in einer der drei Formen (geschärfte Regel · neuer Sensor · benannte Spec-Lücke).
Ein Kandidat steht fest: Die Provenienz-Kette *Asset → vendored Baum* hängt danach an einem
benannten Vorgang statt an Handarbeit — ob das die Aussage in
[`harness/conventions.md`](../../../../harness/conventions.md) §Adoptierte Konventions-Quellen
ändert, ist Architect-Arbeit und gehört als Übergabe in die Closure, nicht in diesen Lauf.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Träger schließt die Provenienz-Lücke nicht, er verlegt sie.** Ein `make`-Ziel, das aus dem
  Asset vendort, macht den *Vorgang* reproduzierbar; dass der **vorhandene** Baum aus dem Asset
  stammt, belegt es rückwirkend nicht. Wer nach diesem Slice sagt, *Asset → Baum* sei bewacht,
  behauptet mehr als der Slice liefert
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). —
  **Ausgang: weiter offen → Beobachtungs-Register**, neuer Eintrag
  [`BEO-ALL/traeger-fuer-den-vorgang-belegt-den-bestand-nicht`](../observations/BEO-ALL/traeger-fuer-den-vorgang-belegt-den-bestand-nicht/observation.md)
  mit `evidence/slice-200.md` (1×). **Nicht *entfallen*, und das ist gemessen:** In den Artefakten
  dieses Slice steht die falsche Aussage nirgends —
  [`harness/conventions.md`](../../../../harness/conventions.md) §Adoptierte Konventions-Quellen
  trägt unverändert *„Asset → vendored Baum hält nichts"*
  (`grep -c 'Asset → vendored Baum\*\* hält nichts' harness/conventions.md` → **1**, kein
  Erwartungswert), und [`harness/README.md`](../../../../harness/README.md) ordnet das Ziel als
  *kein Gate* ein. Eintreten kann sie trotzdem in jedem späteren Text, und kein Sensor hält die
  zwei Ebenen auseinander; *entfallen* verlangt, dass sie nicht mehr eintreten kann.
- **Der Ort der Ziel-Beschreibung ist offen.** Die Ziel-Fassung `v6.5.0` verlangt für ein Gate,
  dessen Vertrag mehr als einen Satz braucht, eine eigene Datei unter `harness/sensors/<target>.md`
  — und das Verzeichnis fehlt (`ls -d harness/sensors 2>/dev/null | wc -l` → 0). Solange es fehlt,
  färbt jede Nennung seines Pfads als Inline-Code `docs-check` rot (Modul `codepaths`, Grund-Code
  `codepath-missing`). Der Slice legt es **nicht** an — das ist die Sensors-Umstellung, ein eigener
  Posten aus
  [slice-193](../done/slice-193-baum-tausch-v650-pins-ziehen.md) §6 §Offene Punkte —, und
  schreibt seine Beschreibung darum in die vorhandene Tabelle. — **Ausgang: entfallen**, mit
  Begründung: Der Slice nennt das noch fehlende Sensors-Verzeichnis an keiner Stelle,
  `make docs-check` meldet `0 Befund(e)`, und es fehlt unverändert
  (`ls -d harness/sensors 2>/dev/null | wc -l` → **0**; der Pfad steht hier als
  **Kommando-Operand**, weil `codepaths` ihn als blanken Inline-Code sonst als fehlendes Ziel
  meldet — dieselbe Falle wie im Reconciliation-Punkt der DoD). Die Beschreibung liegt in
  [`harness/README.md`](../../../../harness/README.md), und zwar als Absatz statt als Tabellen-Zeile
  — der Form der zwei herstellenden Nachbarn folgend, weil die einzige Tabelle dort ausschließlich
  Gates führt. **Der Ort war damit nie offen, sondern falsch angenommen**; diese Hälfte ist keine
  Risiko-Realisierung, sondern ein Plan-Defekt und steht als zweiter Lerneintrag in §7. Die
  Sensors-Umstellung selbst bleibt der Posten in
  [slice-193](../done/slice-193-baum-tausch-v650-pins-ziehen.md) §Offene Punkte, unberührt von
  diesem Ausgang.
- **Ein neuer Aufrufer-Name ist eine Kopplung, die still brechen kann.** Ein falscher **Dateipfad**
  in der Rezept-Zeile fällt laut aus, ein falscher **Unterkommando-Name** geht als Zeichenkette
  durch — der Träger entscheidet erst drinnen, was sie bedeutet. `test/unterkommando-kopplung.bats`
  deckt genau das, und der Slice hat sie zu **nutzen**, nicht zu umgehen. — **Ausgang: entfallen**,
  mit Begründung: Der Name ist genutzt, nicht umgangen, und die Kopplung ist in **beide**
  Richtungen gesehen worden — grün über dem eingereichten Baum, rot über einer Kopie außerhalb des
  Arbeitsbaums, aus der `case "vendor-baseline":` entfernt ist (`not ok 230`,
  [`test/unterkommando-kopplung.bats`](../../../../test/unterkommando-kopplung.bats)). Ein stiller
  Bruch ist damit für **diesen** Namen ausgeschlossen: er hat einen `case` am Zeilenanfang und
  einen Sensor, der seine Abwesenheit rot färbt.
- **Die Fähigkeit war da und wurde nicht gefunden — das ist die eigentliche Klasse.** Der Befund
  ist nicht *„es fehlt ein Ziel"*, sondern *„ein Lauf griff zur Handarbeit, obwohl das Repo den Weg
  führt"*. Ob daraus eine eigene Beobachtung wird, ist ein Urteil und gehört in die Closure; der
  nächstliegende vorhandene Eintrag ist
  [`BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/observation.md)
  — **und er trägt sie nur zur Hälfte**: Er spricht über eine Aussage zum *gepinnten Werkzeug*,
  hier ging es um eine Fähigkeit im *eigenen* Code. Die Bezeichnung ist darum **zitiert** und nicht
  umformuliert; wer sie umschreibt, teilt die Beobachtung in zwei Pfade. — **Ausgang: weiter offen
  → Beobachtungs-Register**, neuer Eintrag
  [`BEO-ALL/vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut`](../observations/BEO-ALL/vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut/observation.md).
  **Sein Beleg ist `slice-193`, nicht `slice-200`:** Dort griff der Lauf zur Handarbeit, hier
  entsteht der Träger — ein Beleg für diesen Vorgang zählte eine Gelegenheit, die er nicht hatte.
  Beide Nachbarn sind einzeln geprüft und tragen ihn nicht: die zitierte Bezeichnung spricht über
  das **gepinnte Fremd-Werkzeug**, und
  [`BEO-ALL/vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin`](../observations/BEO-ALL/vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin/observation.md)
  über die **Bytes des Baums**. Die neue Klasse sagt etwas anderes voraus: ein künftiger Lauf kann
  jede Fähigkeit dieses Repos von Hand nachbauen, ohne den vendored Baum zu berühren.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Rolle:** Planner · **Datum:** 2026-09-08.

- **Was hat funktioniert:** Der **dünne Draht auf eine vorhandene Fähigkeit**. `internal/fetch`
  ist unberührt (`git show --pretty=format: --name-only ae29fe55 ac098942 | grep internal/` ist
  leer), es gibt keinen sechsten Pin-Ort und keine zweite Fassung der Operation; der neue Zweig
  trägt Argument-Parsen, Wurzel-Auflösung und Zielpfad, und beide Letzteren sind aus dem
  Archivierungs-Zweig wiederverwendet. Getragen hat ebenso, dass die zwei Closure-Kriterien als
  **Läufe** formuliert waren und nicht als Zusagen: Reproduktion über dem gepinnten Tag und das
  `sha256`-Gegenbeispiel sind von zwei Rollen unabhängig nachgefahren, je mit demselben
  Baum-Fingerabdruck vor und nach dem Lauf und mit der **gelesenen** Fehlermeldung.
- **Was ging anders als geplant:** Drei Dinge, und alle drei sitzen in Aussagen **über** die
  Arbeit, nicht in ihr.

  **Erstens: die Zusage `kein zweites legt sich daneben` galt an vier Stellen und hielt nur über
  demselben Tag.** Über einem abweichenden Tag legte der Lauf ein zweites `<tag>`-Verzeichnis
  daneben und färbte `make baseline-verify` rot — genau der Fall, für den §1 den Träger begründet.
  Der Ausweg war **nicht**, die Zusage zu verengen: Die Sperre steht jetzt vor dem einzigen
  Netz-Aufrufpunkt, und
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  Setzung 4 kann durch dieses Ziel nicht mehr verletzt werden.

  **Zweitens: ein Test-Kommentar nannte ein Gegenbeispiel, das seinen Test nicht rot färbt.**
  Entfernt man den Dispatch-`case`, bleibt der Go-Satz grün — die Sperre in `run()` beantwortet
  jedes Positionsargument gleich, mit oder ohne ihn. Die Eigenschaft **ist** gedeckt, nur von
  einem anderen Wächter (`test/unterkommando-kopplung.bats`, in der Gegenprobe rot gesehen).

  **Drittens: die Beleg-Zahl im Ziel-Absatz misst jetzt ihren Gegenstand, und dafür brauchte sie
  zwei Korrekturen.** Der Satz *„die zwei Quellen unterschieden sich in N Dateien"* stand zuerst
  ohne Kommando im Absatz und dann mit einem, das eine **Link-Form** zählt statt der Differenz
  zweier Quellen. Die zweite Fassung war damit formgerecht nach
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 — eine Zahl, ein Kommando daneben, gefahren — und traf den Satz trotzdem nicht; für ihn
  war sie eine Untergrenze und keine Größe. Der heutige Wert kommt aus einem Diff über die zwei
  Tree-Operanden des Tausch-Commits und ist von zwei Rollen unabhängig nachgefahren.
- **Steering-Loop-Eintrag — benannte Spec-Lücke, gegen
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 und
  [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung):**
  *Der Zahl-Beleg bindet das lebende Artefakt und zwei benannte Träger daneben — er bindet nicht
  die zwei Zeitdokumente, über die eine Zahl **in** ein lebendes Artefakt gelangt.* Ein
  Rollen-Report und eine Closure-Notiz sind Chronik von Beruf und liegen außerhalb des
  Geltungsbereichs; eine Zahl, die durch sie läuft, kommt im lebenden Text bereits belegt aussehend
  an, weil sie unterwegs ein Kommando bei sich trug — nur eines, das eine andere Menge zählt.
  [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  hat die Frage für die Commit-Message bereits gestellt und dort mit der **Haltbarkeit des
  Trägers** beantwortet (*„eine Message verliert gar nichts"*); die Weitergabe-Achse ist eine
  andere und in keiner der zwei Setzungen entschieden. **Kein neuer Sensor wird hier behauptet**
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)):
  Kein Modul aus `modules:` der [`.d-check.yml`](../../../../.d-check.yml) hält eine Prosa-Zahl
  gegen ihren Gegenstand, und `make mutate` kennt dafür keine Fehlschlag-Form. Ob der
  Adaptions-Block eine dritte Setzung bekommt, entscheidet der **Architect**
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8); dieser Eintrag ist **gezählt, nicht verkörpert** —
  die Teil-Zeile `liegt in` entfällt ersatzlos.
- **Zweiter Lerneintrag — Plan-Defekt, kein Liefer-Defekt.** §3 dieses Plans führt
  [`AGENTS.md`](../../../../AGENTS.md) §4 als `update`, und §6 verlangt die Beschreibung *„in die
  vorhandene Tabelle"*. Beides trägt am Bestand nicht, und beide Prüf-Rollen haben es unabhängig
  gemessen: Die Tabelle in §4 führt genau die zehn `record-gates`-Voraussetzungen plus `make gates`
  (`awk '/^## 4\. Quality Gates/,/^## 5\./' AGENTS.md | grep -oE 'make [a-z-]+' | sort -u | wc -l`
  → **11**, gegen `sed -n 's/^record-gates: \(.*\)  *##.*/\1/p' Makefile` → dieselben zehn; keine
  Erwartungswerte), und die einzige Tabelle in
  [`harness/README.md`](../../../../harness/README.md) §Sensors führt ausschließlich Gates. Ein
  **herstellendes** Ziel dort einzutragen liefe gegen
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — die
  zwei herstellenden Nachbarn stehen aus demselben Grund als Absatz. **Die geschärfte Regel:** Ein
  Plan-Punkt, der einen Zielort zum `update` benennt, misst vorher, ob die Norm dieses Zielorts ihn
  trägt; sonst schreibt der Plan eine Verletzung vor und die Umsetzung muss gegen ihn recht
  behalten. Sie hat heute **keinen Zielort**: Die Slice-Vorlage liegt vendored und wird nicht
  angefasst, und die Zusammensetzungs-Regel von §4 ist Architect-Gegenstand
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Auch dieser Eintrag ist damit gezählt, nicht
  verkörpert — **Übergabe an den Architect**, zusammen mit der Frage aus §5, ob die Aussage
  *„Asset → vendored Baum hält nichts"* in
  [`harness/conventions.md`](../../../../harness/conventions.md) §Adoptierte Konventions-Quellen
  durch diesen Träger zu ändern ist (sie steht heute unverändert und ist es nach §6, erstem Risiko,
  auch zu Recht).
- **Beobachtungs-Register (`../observations/`):** **sechs Belege**, je genau eine Datei — ein
  Vorgang zählt einmal, auch wo ein Fund mehrfach auftrat. Zähler sind Dateizahlen und stehen in
  keinem Feld (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, keine
  Erwartungswerte). **Drei gehen in bestehende Einträge:**
  [`kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md)
  (→ **3×**; die zwei Funde HIGH-1 und LOW-1 sind eine Gelegenheit) ·
  [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  (→ 9×, die viermal wiederholte Tag-Zusage) ·
  [`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md)
  (→ 2×, die Beleg-Zahl oben). **Drei Einträge sind neu**, und für jeden ist geprüft, dass kein
  vorhandener ihn trägt:
  [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  (→ 1×; die Bezeichnung stammt aus dem Review, und dass sie im Register fehlt, ist von der
  Verifikation eigens gemessen worden) ·
  [`traeger-fuer-den-vorgang-belegt-den-bestand-nicht`](../observations/BEO-ALL/traeger-fuer-den-vorgang-belegt-den-bestand-nicht/observation.md)
  (→ 1×, §6 erstes Risiko) ·
  [`vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut`](../observations/BEO-ALL/vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut/observation.md)
  (→ 1×, §6 viertes Risiko — **Beleg `slice-193`**, siehe dort).

  **Ein Eintrag überschreitet mit diesem Slice die Schwelle** —
  `kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle` — und steht bis zum Lese-Schritt
  weiter auf `offen`; zulässig und vorübergehend nach `v6.5.0` · `regelwerk/modul-06-roadmap.md`
  §Das Beobachtungs-Register. **Der Sichtungs-Schritt §8 führt ihn nicht**, und das ist kein
  Widerspruch: Er kommt aus der dritten Quelle einer Closure — der wiederkehrenden Finding-Klasse
  des Reviews (`modul-05-planning-harness.md` §Closure- und Lerneintrag-Regeln) —, und die steht
  beim Schreiben des Plans nicht zur Verfügung. **Den Lese-Schritt trägt in einem Repo mit Wellen-Betrieb die
  Welle-Closure** (`modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle, Schritt 3a), und
  dieses Repo führt zwei offene Wellen (`welle-09`, `welle-13`, Zeiger unter *Offene Wellen* der
  Roadmap). Die Übergabe steht hier, nicht der Ausgang — stellvertretend entschieden wäre es eine
  Zuständigkeit, die diese Rolle nicht hat.

  **Zwei Funde bekommen bewusst keinen Beleg.** Der Slice ist die **Antwort** auf
  [`vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin`](../observations/BEO-ALL/vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin/observation.md)
  und kein weiteres Auftreten; seine `state.md` nennt jetzt den vorhandenen Träger statt eines
  zugesagten. Und INFO-3 des Reviews (die Bezugsmenge der Verdrahtungs-Zahl) ist im selben Vorgang
  behoben — der Satz nennt seither jede Achse, die das Kommando zählt —, ein Beleg zählte hier eine
  Gelegenheit, keine Wiederholung.
- **Folge-Slices:** keiner geschnitten. Die Mutations-Deckung ist als Beobachtung geführt und nicht
  als Slice: Sie steht bei 1×, und ein Folge-Slice je Erstauftreten ist genau der Mechanismus, den
  das Register ersetzt.
- **Trigger-Audit:** `CO-001` — Trigger weiterhin **eingetreten**, Ausgang unverändert *verlängert
  mit Folge-Slice*; die zwei Träger sind Dateien im Lifecycle (`slice-141` entscheidet vorher,
  `slice-113` führt aus). Die `Letzte Prüfung:`-Zeile jener Datei bleibt beim Stand des
  welle-10-Audits: In einem Repo mit Wellen-Betrieb ist das Carveout-Audit Schritt 2 der
  Welle-Closure, und eine zweite Eintragung desselben Ergebnisses wäre Chronik. `CO-002` —
  **permanent**, in [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md)
  übergeführt, keine Handlung. Weitere Carveouts führt
  [`docs/plan/carveouts/`](../../carveouts/) außerhalb von `done/` nicht
  (`ls docs/plan/carveouts/CO-*.md | wc -l` → **2**, kein Erwartungswert). Bootstrap-aware Gates
  führt dieses Repo keine. **ADR-Re-Evaluierungs-Trigger im Gegenstand dieses Slice:** keiner
  gefeuert — [`ADR-0003`](../../adr/0003-go-native-binaries.md) und
  [`ADR-0007`](../../adr/0007-bootstrap-phasen.md) sind `Accepted` und unberührt, und
  [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 1 trägt den
  Träger-und-Unterkommando-Weg, den dieser Slice ein zweites Mal geht, ohne ihn zu ändern. Ein
  neuer Architektur-Beschluss ist nicht nötig; das hat das Review als Negativbefund gemessen.
- **Risiken aus §6:** alle vier tragen genau einen Ausgang — **2× entfallen mit Begründung** (der
  Ort der Ziel-Beschreibung war nie offen, sondern falsch angenommen; die Unterkommando-Kopplung
  ist genutzt und in beide Richtungen gesehen), **2× weiter offen ins Register**
  (`traeger-fuer-den-vorgang-belegt-den-bestand-nicht` ·
  `vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut`). Kein Risiko ist *eingetreten*:
  Der einzige Kandidat wäre die Zusage, die Provenienz-Kette sei jetzt bewacht, und die steht in
  keinem Artefakt dieses Slice.
- **Drei Paarungen:** dieses Repo führt Wellen-Betrieb; sie prüft die nächste Welle-Closure — auch
  für einen Slice ohne Wellen-Zugehörigkeit. **Nachgesehen und übergeben statt behauptet:**
  (a) **Anker-Paarung** hat keinen Gegenstand — dieser Slice verkörpert nichts und trägt kein Feld
  `liegt in`. (b) **Folge-Slice-Paarung** grün: die genannten `slice-141` und `slice-113` sind
  Dateien im Lifecycle. (c) **Register-Paarung**, erste Hälfte grün — jede hier zitierte Beobachtung
  existiert als Verzeichnis; zweite Hälfte unverändert **rot**, an denselben zwei Einträgen wie
  zuvor, `benannte-luecke-ohne-ausgang` und
  `einstiegs-datei-weicht-von-der-pflichtgliederung-ab`, beide mit leerem `evidence/`
  (`for d in docs/plan/planning/observations/BEO-ALL/*/; do [ -z "$(ls "$d"evidence/*.md 2>/dev/null)" ] && basename "$d"; done`).
  Dieser Slice hat keinen von beiden erzeugt und schließt keinen. **Der Befund für die
  Welle-Closure ist gewachsen:** Fünf Einträge stehen bei 3× oder darüber und tragen `offen` —
  `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`,
  `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`, `zaehler-label-nennt-falsche-einheit`,
  `zitat-grep-uebersieht-zeilenumbruch-und-markup` und ab jetzt
  `kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`. Das ist die Klasse
  `schwellen-uebertritt-ohne-zustaendige-rolle` (2×) — **benannt, nicht gezählt**: Ein Beleg käme
  aus einer Closure, die den Lese-Schritt gar nicht trägt, und zählte damit eine Zuständigkeit, die
  sie nie hatte.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind **zwei** Sub-Areas: `*` (`ALL`) für
`Makefile`, `cmd/` und die Gate-Beschreibungen — und **nicht** `harness/tools/` (`TOOLS`): Der
Träger ist das Produkt-Binär, kein Shell-Helfer
([`ADR-0003`](../../adr/0003-go-native-binaries.md)). `.codex/` (`CODEX`) ist nicht berührt.
Bringt der Lauf doch einen Shell-Helfer mit, ist `TOOLS` nachzutragen und der Modus je Sub-Area
einzeln zu begründen — nicht gebündelt.

**Vorgelagert — offene Beobachtungen sichten:** Das Register unter
[`../observations/`](../observations/) ist durchgegangen; es führt **65** Verzeichnisse
(`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, kein Erwartungswert), alle unter
`BEO-ALL`. Diesen Vorgang betreffen — Zähler als Dateizahl unter `evidence/` abgelesen
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`):

| Eintrag | Zähler | Stand | Bezug zu diesem Slice |
|---|---|---|---|
| `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` | 1× | offen | die halbe Deckung des eigentlichen Befunds — §6 viertes Risiko |
| `baseline-sprungweite-treibt-kosten` | 1× | offen | der Träger senkt die Kosten je Sprung; er ändert die Sprungweite nicht |
| `re-baseline-ohne-inventur-slice` | 2× | offen | derselbe Vorgang, andere Hälfte: dieser Slice gibt dem **Vollzug** ein Werkzeug, nicht der **Inventur** |
| `gruen-aussage-ohne-herkunft` | 1× | offen | genau §6 erstes Risiko — ein grünes `baseline-verify` sagt nichts über die Herkunft des Baums |
| `vollstaendigkeits-zusage-misst-falsche-ebene` | 1× | offen | *Vorgang* reproduzierbar ≠ *Bestand* belegt; die zwei Ebenen sind in §6 getrennt gehalten |

**Kein Eintrag erreicht mit diesem Slice 3×**, vorausgesetzt die Closure legt ihre Belege so, wie
§6 sie vorzeichnet. Alle Bezeichnungen sind **zitiert**, nicht neu formuliert.

**Modus:** alle berührten Sub-Areas **GF** — der Begründungsblock entfällt damit nach der
Umfangs-Regel dieser Sektion.

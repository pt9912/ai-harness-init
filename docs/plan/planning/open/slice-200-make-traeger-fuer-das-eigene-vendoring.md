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

**Verantwortlich:** — (bis zur Priorisierung; Implementer-Arbeit).

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

- [ ] **Ein `make`-Ziel legt den vendored Baum aus dem verifizierten Asset an**, gefahren über den
      Träger aus [`ADR-0003`](../../adr/0003-go-native-binaries.md) — kein Host-Werkzeug in der
      Befehlsposition ([`AGENTS.md`](../../../../AGENTS.md) §3.9). Es liest den Tag und den
      `sha256` aus den **kanonischen** Makefile-Variablen `BASELINE_TAG`/`BASELINE_ZIP_SHA256`
      (`grep -nE '^BASELINE_(TAG|ZIP_SHA256)' Makefile`), nicht aus einem zweiten Wert, und bricht
      bei Abweichung ab, statt zu schreiben. Nach dem Lauf meldet `make baseline-verify` `OK` und
      `ls -d .harness/baseline/v*/ | wc -l` gibt `1`.
- [ ] **Der Lauf ist über denselben Tag wiederholbar und liefert byte-gleiche Bäume** —
      [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), gemessen als
      Fingerabdruck des Baums vor und nach einem zweiten Lauf, nicht zugesagt. **Und ein Lauf mit
      falschem `sha256` färbt rot:** Das ist das rot zu sehende Gegenbeispiel
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6) — ohne es ist nicht belegt, dass die Prüfung
      überhaupt greift, sondern nur, dass der Happy Path läuft. Der Lauf-Bericht nennt die gelesene
      Fehlermeldung; ein Abbruch lässt den vorhandenen Baum **unverändert**.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update für <Schnittstelle X> falls öffentlicher Vertrag berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register fortgeschrieben, **falls dieser Slice einen Inventur-Fund auflöst** —
      Zeile mit Datum und auflösendem Artefakt nach *Aufgelöste Einträge* verschoben. **Entfällt
      hier:** Repos ohne Brownfield-Bootstrap haben die Datei nicht, und dieses führt sie nicht
      (`ls docs/plan/planning/reconciliation.md` → nicht vorhanden). Der Pfad steht als
      **Kommando-Operand**, weil die vendored Vorlage ihn als blanken Inline-Code führt und
      `codepaths` ihn dann als fehlendes Ziel meldet — dieselbe Stelle, die
      [slice-193](../done/slice-193-baum-tausch-v650-pins-ziehen.md) §6 als offenen Punkt
      führt.
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
auf [slice-197](../next/slice-197-eingefrorene-baseline-adresse-bekommt-ihr-ventil.md).

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
  **Ausgang:** offen; die Closure setzt ihn.
- **Der Ort der Ziel-Beschreibung ist offen.** Die Ziel-Fassung `v6.5.0` verlangt für ein Gate,
  dessen Vertrag mehr als einen Satz braucht, eine eigene Datei unter `harness/sensors/<target>.md`
  — und das Verzeichnis fehlt (`ls -d harness/sensors 2>/dev/null | wc -l` → 0). Solange es fehlt,
  färbt jede Nennung seines Pfads als Inline-Code `docs-check` rot (Modul `codepaths`, Grund-Code
  `codepath-missing`). Der Slice legt es **nicht** an — das ist die Sensors-Umstellung, ein eigener
  Posten aus
  [slice-193](../done/slice-193-baum-tausch-v650-pins-ziehen.md) §6 §Offene Punkte —, und
  schreibt seine Beschreibung darum in die vorhandene Tabelle. — **Ausgang:** offen; die Closure
  setzt ihn.
- **Ein neuer Aufrufer-Name ist eine Kopplung, die still brechen kann.** Ein falscher **Dateipfad**
  in der Rezept-Zeile fällt laut aus, ein falscher **Unterkommando-Name** geht als Zeichenkette
  durch — der Träger entscheidet erst drinnen, was sie bedeutet. `test/unterkommando-kopplung.bats`
  deckt genau das, und der Slice hat sie zu **nutzen**, nicht zu umgehen. — **Ausgang:** offen; die
  Closure setzt ihn.
- **Die Fähigkeit war da und wurde nicht gefunden — das ist die eigentliche Klasse.** Der Befund
  ist nicht *„es fehlt ein Ziel"*, sondern *„ein Lauf griff zur Handarbeit, obwohl das Repo den Weg
  führt"*. Ob daraus eine eigene Beobachtung wird, ist ein Urteil und gehört in die Closure; der
  nächstliegende vorhandene Eintrag ist
  [`BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/observation.md)
  — **und er trägt sie nur zur Hälfte**: Er spricht über eine Aussage zum *gepinnten Werkzeug*,
  hier ging es um eine Fähigkeit im *eigenen* Code. Die Bezeichnung ist darum **zitiert** und nicht
  umformuliert; wer sie umschreibt, teilt die Beobachtung in zwei Pfade. — **Ausgang:** offen; die
  Closure setzt ihn.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<NNN>` (<slice-NNN>, <slice-MMM>, <slice-KKK> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-NNN.md` | `evidence/slice-NNN.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-NNN (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

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

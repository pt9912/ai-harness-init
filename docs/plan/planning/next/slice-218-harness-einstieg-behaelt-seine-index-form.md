# Slice slice-218: Die Vertrags-Zellen des Harness-Einstiegs bekommen eine gemessene Grenze

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die von der DoD dieses Slice verschieden
wäre — der Trigger wäre die eigene DoD abgeschrieben (Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht). Und [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) §6
nimmt `structure` **namentlich** aus ihrem Umfang aus; ihn nachträglich hineinzuziehen änderte
ihre Identität, statt diesen Slice zu tragen.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(kein Gate ohne rot gesehenes Gegenbeispiel) · Gate-*Anheben* ist ein Steering-Loop nach
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids),
**kein ADR** ([`AGENTS.md`](../../../../AGENTS.md) §3.5 bindet Senkungen).

**Berührte Spec-Stellen:** — (keine; die Modul-Menge des Doku-Gates führt kein Spec-Stratum).

**Verantwortlich:** Implementer (pt9912). Der Liefergegenstand ist Gate-Konfiguration, ein
hermetischer Test und ein Mutations-Fall — keine Norm-Aussage, also kein Architect-Artefakt
([`AGENTS.md`](../../../../AGENTS.md) §3.8).

**Autor:** Planner. **Datum:** 2026-09-12.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Die zwei Vertrags-Spalten des Harness-Einstiegs — `Vertrag` in §Sensors und `Tut was` in
§Werkzeuge — bekommen im Doku-Gate eine Zeichen-Obergrenze, damit die Index-Form, die slice-114
gerade hergestellt hat, nicht Zelle für Zelle wieder zur Restliste wird.

### Die Bezugsmenge existiert heute — anders als bei slice-214

```sh
awk -F'|' '/^#+ / { s = /Sensors/ ? "Vertrag" : /Werkzeuge/ ? "Tut was" : "" }
  s && /^\|/ && NF>2 && $0 !~ /^\|[- :]+\|/ { n=length($3); c[s]++; if(n>m[s])m[s]=n }
  END { for (k in m) printf "%-8s %2d Zellen, max %3d\n", k, c[k], m[k] }' harness/README.md
#   Vertrag  12 Zellen, max 145
#   Tut was  18 Zellen, max  83
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — sie wandern mit der Datei. Darin unterscheidet sich dieser Slice von
[slice-214](../open/slice-214-zellengrenze-wird-gemessen-statt-gesetzt.md), dessen Wert auf
Report-Zellen wartet, die es noch nicht gibt: **hier** ist er jetzt begründbar.

### Die Regel, nach der der Wert gewählt wird — und der Wert

Der Wert liegt **über** dem heutigen Maximum (eine Grenze, die den Bestand schon beim Setzen
bricht, ist ein Rückbau und kein Gate) und **unter** dem Maximum des Stands, den slice-114 abgelöst
hat — sonst fängt sie nichts, was in diesem Repo je vorkam. Das zweite Ende ist über demselben Baum
gemessen:

```sh
git show 9a57f2b3^:harness/README.md | awk -F'|' '/^\|/ && NF>2 && $0 !~ /^\|[- :]+\|/ {
  n=length($3); if(n>mx)mx=n } END { print mx }'   # 181
```

Das Fenster ist `[146, 180]`; gewählt ist **180**, sein oberes Ende — maximale Luft für legitimes
Wachstum, ohne die Eigenschaft zu verlieren. Der Fall am oberen Ende ist kein konstruierter: Es ist
genau die `make docs-check`-Zelle, die slice-114 von 181 auf 145 kürzen musste, indem er ihre Prosa
nach `harness/sensors/doc-check.md` <!-- d-check:ignore (Pfad zum zitierten Commit-Stand, die Datei heißt inzwischen anders) --> gab. **180 ist eine Setzung innerhalb eines gemessenen
Fensters**, nicht die Messung selbst; wandert das Fenster, ist das eine Änderung an diesem Plan.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein `structure`-Prüfbereich über `docs/reviews/**`.** Die Form dort schneidet
  [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md), den Grenzwert dazu
  [slice-214](../open/slice-214-zellengrenze-wird-gemessen-statt-gesetzt.md). Beide **ergänzen**
  danach Regeln in demselben Block — das ist kein Konflikt, sondern eine Reihenfolge (§6).
  *(Folge-Slice mit Kennung — beide nehmen die Sendung an, keiner schließt den Punkt aus.)*
- **Keine Abschnitts-Selektoren über der Pflichtgliederung.** Ein `structure:`-Selector je
  Pflicht-Abschnitt des Einstiegs fängt `section-missing` und ist im Trockenlauf von slice-114
  gemessen; er deckelt aber nichts, sondern verlangt Anwesenheit — anderer Gegenstand, andere
  Fehlerrichtung, eigener Schnitt. Die Adresse steht in §6. *(Anderer Vorgang.)*
- **[`harness/README.md`](../../../../harness/README.md) wird nicht umgeschrieben.** Genau **eine**
  Zelle wird nachgezogen — die `make doc-structure`-Zeile sagt heute *„inert ohne
  `structure:`-Block"*, und der Block entsteht mit diesem Slice
  ([`AGENTS.md`](../../../../AGENTS.md) §3.7: ein Zustandsfeld beschreibt, was da ist). Jedes
  weitere Byte bleibt stehen. *(Bestand bleibt bewusst stehen.)*
- **Keine Änderung an der emittierten Doc-Gate-Startkonfiguration.** Ebene Dogfood; was ein
  emittiertes Repo an Modulen bekommt, hängt an
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  und ist ein eigener Schnitt. *(Schicht-Abgrenzung, Dogfood gegen emittiert.)*

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

Drei slice-eigene Punkte. Der dritte ist keine Zugabe, sondern die mechanische Folge des ersten:
`test/doc-block-marke-wiring.bats` (in `make gates`) leitet ab, welche `doc-*`-Ziele ein Modul
zuschalten, für das [`.d-check.yml`](../../../../.d-check.yml) **keinen** eigenen Block führt —
mit dem Block fällt `doc-structure` aus dieser Menge, und die Marke muss weg, sonst ist der Gate
rot. [slice-217](../in-progress/slice-217-doc-ziel-nennt-seinen-pruefbereich.md) §6 führt genau
diesen Fall bereits als Risiko.

- [ ] **(1) Die Grenze steht, grüner Start und rotes Gegenbeispiel im Repo.** `structure` in
      `modules:` und ein `structure:`-Block mit `cell-max-chars: 180` auf beide Vertrags-Spalten
      (Schlüsselform `table.column[].cell-max-chars`, am gepinnten Digest aus
      [`d-check.mk`](../../../../d-check.mk) gemessen, nicht angenommen). `make docs-check` ist
      über dem unveränderten `harness/README.md` grün; eine Zelle über 180 Zeichen färbt
      `section-cell-oversized` auf **ihrer** Zeile, mit Spaltenname und Zeichenzahl. Beide Läufe
      stehen im Umsetzungs-Commit, **das Rot je Spalte einzeln** — ein Selector, der nur eine
      trifft, ist über der anderen still grün
      ([`BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr`](../observations/BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr/observation.md)).
- [ ] **(2) Der neue Wächter hat einen Zahn.** `test/structure-modul-wiring.bats` hält
      Modul-Aktivierung, Selector und den Wert `180` hermetisch gegen Regression — dieselbe Bauart
      wie `test/planning-modul-wiring.bats` und `test/vcs-modul-wiring.bats`, ohne Docker-Lauf. Ein
      Fall unter `test/mutations/` mit `# verify: test-bats` nimmt dem Wert die Zähne und **muss**
      diesen Test röten. *(`make mutate` kennt keinen `docs-check`-Modus: `failure_form()` in
      `harness/tools/mutate.sh` führt sechs, keiner fährt das Doku-Gate. Der Zahn sitzt deshalb auf
      dem hermetischen Wächter — die im Repo etablierte Route, keine Ersatzhandlung.)*
- [ ] **(3) `doc-structure` verlässt die C-Klasse sauber.** Die Marke fällt aus `##`-Hilfetext und
      Ausgabe-Zeile des Rezepts in [`d-check.mk`](../../../../d-check.mk),
      `test/doc-block-marke-wiring.bats` bleibt grün, und die Inertheits-Aussage in
      [`harness/sensors/doc-structure.md`](../../../../harness/sensors/doc-structure.md) wird
      **abgelöst**, nicht ergänzt — samt der einen Zelle in
      [`harness/README.md`](../../../../harness/README.md) (§1).

Standard-Punkte der Vorlage (nicht slice-eigen, zählen nicht zur Drei):

- [ ] `make gates` grün · `make mutate` ohne Befund.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: die Grenze und ihre Bezugsmenge stehen in
      [`harness/sensors/doc-structure.md`](../../../../harness/sensors/doc-structure.md) — dort,
      wo dieses Repo die Prosa eines Sensors führt, und mit dem Kommando daneben
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
      [`harness/README.md`](../../../../harness/README.md) bekommt keine neue Prosa (§1).
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
| [`.d-check.yml`](../../../../.d-check.yml) | update | DoD (1): `structure` in `modules:`, `structure:`-Block mit beiden Vertrags-Spalten und `cell-max-chars: 180` |
| `test/structure-modul-wiring.bats` | neu | DoD (2): hält Aktivierung, Selector und Wert hermetisch — Vorbild `test/planning-modul-wiring.bats` |
| `test/mutations/` | neu | DoD (2): der Zahn über dem Wert, `# verify: test-bats` |
| [`d-check.mk`](../../../../d-check.mk) | update | DoD (3): die Marke fällt aus Hilfetext und Ausgabe-Zeile des `doc-structure`-Rezepts |
| [`harness/sensors/doc-structure.md`](../../../../harness/sensors/doc-structure.md) | update | DoD (3): die Inertheits-Aussage wird abgelöst; hier steht die Grenze mit ihrer Bezugsmenge |
| [`harness/README.md`](../../../../harness/README.md) | update | **eine** Zelle: `inert ohne structure:-Block` trifft nicht mehr zu (§1) |
| [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) | **unverändert** | Reviewer-Eigentum ([ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)); der Report-Prüfbereich gehört slice-213/214 |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-217](../in-progress/slice-217-doc-ziel-nennt-seinen-pruefbereich.md) **und**
[slice-114](../in-progress/slice-114-jede-aussage-hat-einen-abschnitt.md) liegen in `done/`.
Beobachtbar ohne Rückfrage (`ls docs/plan/planning/done/`) und **kein Ergebnis dieses Slice**.
Beide sind harte Kanten: 217 baut die C-Klassen-Ableitung, die DoD (3) benutzt und verkleinert —
parallel geführt schreiben beide dasselbe Rezept und denselben Wächter; 114 stellt die Bezugsmenge
her, gegen die §1 misst.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die zwei Spalten je einen eigenen
  Cutoff-Durchgang verlangen (etwa weil der Selector nur eine von beiden trifft) — Schnitt dann je
  Spalte einer.
- `in-progress` → `open` (blockiert — Carveout?): wenn der gemessene Selector das Modul auf die
  zwei Tabellen **nicht** eingrenzen kann und jeder Block den ganzen Baum trifft. Dann ist die
  Antwort nicht ein stillschweigend geweiteter Prüfbereich, sondern ein Carveout oder die
  begründete Feststellung, dass `structure` diese Frage nicht trägt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. `make gates` ist grün mit gesetztem `cell-max-chars` über dem unveränderten
   `harness/README.md`, und `make mutate` meldet keinen Befund.
2. Das Rot ist **im Repo** gesehen — `section-cell-oversized`, je einmal für jede der zwei
   Spalten, Läufe im Umsetzungs-Commit protokolliert; und der Mutations-Fall aus DoD (2) fällt,
   wenn ihm die Zähne genommen werden.
3. Closure-Notiz mit Steering-Loop-Lerneintrag.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **180 schreibt den Ausreißer fest.** Der grüne Start ist damit erkauft, dass die längste
  bestehende Zelle die Grenze mitdefiniert; wer künftig eine 179-Zeichen-Zelle schreibt, bleibt
  still. — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: Register>
- **Die Grenze trifft die Zelle, nicht die Datei.** Prosa **außerhalb** der Tabellen bleibt
  ungeregelt — `harness/README.md` kann beide Spalten halten und trotzdem wieder wachsen. Die
  Masse-Frage ist die, an der slice-114 ausdrücklich haltmacht. — **Ausgang:** <…>
- **Der Prüfbereich wird beim Schreiben zu breit.** Zielt der Block auf die Spalten**namen** statt
  auf die zwei Abschnitte, trifft er jede gleichnamige Spalte im Baum und meldet gegen Bestand, den
  niemand entschieden hat — dieselbe Klasse, die der `scan.ignore`-Kommentar in
  [`.d-check.yml`](../../../../.d-check.yml) für sich führt. DoD (1) verlangt den Nachweis je
  Spalte, nicht die Abwesenheit von Befunden. — **Ausgang:** <…>
- **Der Zahn misst den Wächter, nicht das Gate.** Wird die Zeile in
  [`.d-check.yml`](../../../../.d-check.yml) so verändert, dass `test/structure-modul-wiring.bats`
  sie noch findet, das Modul aber nicht mehr greift, bleibt beides grün. — **Ausgang:** <…>
- **Offen: braucht `make mutate` einen `docs-check`-Modus?** Jeder Gate-Modul-Slice dieses Repos
  weicht auf einen hermetischen Wächter aus, weil `failure_form()` keinen führt. Ob das die
  Dauerform ist oder eine gewachsene Lücke, entscheidet **nicht** dieser Slice — die Frage gehört
  zur Klasse
  [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  und braucht einen eigenen Schnitt.
  — **Ausgang:** <eingetreten: slice-NNN | entfallen: Grund | weiter offen: Register>
- **Offen: die acht Pflicht-Abschnitte bleiben ohne Selector** (§1). Die Adresse dafür ist ein
  Folge-Slice, der mit der Closure zu schneiden ist.
  — **Ausgang:** <eingetreten: slice-NNN | entfallen: Grund | weiter offen: Register>
- **slice-213/214 finden einen belegten Block vor.** Beide planen heute die *Aktivierung*; danach
  ist ihr Anteil das *Hinzufügen* einer Regel — eine Anpassung ihrer Pläne in `open/`, kein
  Umplanen. Verschwiegen wäre es eine stille Plan-Änderung. — **Ausgang:** <…>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

Drei Posten sind vorgemerkt: das Ergebnis der zwei Rot-Läufe je Spalte, der Ausgang der offenen
Punkte aus §6 (`docs-check`-Modus für `make mutate`, Abschnitts-Selektoren) und die Anpassung, die
slice-213/214 durch diesen Slice bekommen.

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Vorgelagert — Sub-Area-Wahl prüfen:** **Eine** berührte Sub-Area, `*` (gesamtes Repo, Kürzel
`ALL`) aus der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) — der Gegenstand ist die
Gate-Konfiguration des Repos und liegt quer zu jeder engeren Familie. `TOOLS`
(`harness/tools/`) ist **nicht** berührt: `harness/tools/mutate.sh` wird gelesen (§6), nicht
geändert.

**Vorgelagert — offene Beobachtungen sichten:** Drei Treffer, Zähler-Stände am gemergten Stand
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, keine Erwartungswerte):

- [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  — **12**. Die schärfste Klasse hier: die Zusage *„die Vertrags-Zellen sind gedeckelt"* trägt nur,
  wenn der Selector beide Spalten wirklich trifft — DoD (1) verlangt deshalb je Spalte ein Rot
  statt einer Null.
- [`zusicherung-ueber-der-leeren-menge-wahr`](../observations/BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr/observation.md)
  — **1**. Dieselbe Fehlerrichtung im Wächter aus DoD (2): eine Zusicherung über einer Liste, die
  sie sich selbst besorgt, ist grün, wenn die Liste leer ist.
- [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  — **4**, Stand `offen`. Dieser Slice **erhöht ihn nicht**: DoD (2) liefert den Fall. Dass der
  Eintrag über der Schwelle steht und noch keinen Ausgang trägt, ist ein Befund am Register und
  nicht an diesem Slice; die Frage, die er für `docs-check` aufwirft, steht in §6.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF — ein Block, `ALL`.

### Sub-Area: `*` (gesamtes Repo, `ALL`)

- **Modus:** GF. Die Gate-Konfiguration ist in diesem Repo entstanden; es gibt keinen
  vorgefundenen Fremd-Bestand, gegen den zu inventarisieren wäre.
- **Konventionen-Dichte:** hoch. Die Form eines Modul-Blocks ist im Adaptions-Block mehrfach
  verankert — [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  (Gate-Anheben als Steering-Loop),
  [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
  (ein Durchsetzungspunkt, kein zweites Profil) — und vier Vorgänger-Blöcke tragen je einen
  hermetischen Wiring-Wächter.
- **Phase-Reife:** Phase 5 (Betrieb). `make docs-check` läuft in `make gates` und in CI.
- **Evidenz-/Diskrepanz-Risiko:** mittel, und es liegt beim Prüfbereich, nicht beim Bestand — die
  zwei Treffer oben benennen genau die Richtung, in der ein zu breiter oder ins Leere zeigender
  Selector still grün bliebe. Der Bestand selbst ist mit §1 gemessen.
- **Reconciliation-Aufwand:** gering. Ein Modul-Block, ein Wächter, ein Mutations-Fall, dazu die
  erzwungene C-Klassen-Nachführung aus DoD (3). Graduation-Trigger entfällt (bereits GF).

# Slice slice-177: Das Beobachtungs-Register läuft in der Verzeichnis-Form

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-15](../welle-15-re-baseline.md) — **Mitglied, und der Grund ist gemessen statt
zweckmäßig.** Der Zuschnitt-Test ist nicht *„braucht diese Arbeit eine Welle?"*
([`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)),
sondern *„ist die Ablage-Form eine Pflicht der Ziel-Fassung?"* — und sie ist es: `v6.0.0` ersetzt
die Register-Vorlage durch eine Vorlage je **Beobachtung** und schreibt `modul-06-roadmap.md`
§Das Beobachtungs-Register darauf um (Beleg in §1). Damit fällt die Arbeit unter das Welle-Ziel
*„jede Pflicht, die die neue Fassung mitbringt, hat einen verbuchten Ausgang"*. Die Präzedenz
[slice-166](../done/slice-166-adaptions-block-wird-ein-verzeichnis.md)/[slice-167](../done/slice-167-aufgeloeste-adaptionen-bekommen-ihre-verzeichnis-position.md)
lief **wellenlos**, weil die Verzeichnis-Form des Adaptions-Blocks eine repo-eigene Setzung war
([`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form))
und keine Pflicht des damals adoptierten Stands.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Ziel-Form
kommt aus dem auf einen Tag gepinnten Baum),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
maschinelle Hälfte der Register-Paarung ändert mit der Ablage ihren Gegenstand — was heute kein
Modul prüft, prüft es danach ebenso wenig),
[`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)
(die Präzedenz derselben Form-Umstellung in diesem Repo),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(die Ziel-Form liegt im vendored Baum, und der wird vorher getauscht).

**Berührte Spec-Stellen:** `—`. Der Slice bewegt ein Planning-Artefakt; er schreibt keine
Spec-Stelle.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-04.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Zwei Closures, die verschiedene Beobachtungen anfassen, schreiben in verschiedene Dateien — und
zwei Belege zu derselben Beobachtung ebenfalls.** Heute schreibt **jede** Slice-Closure in dieselbe
Datei, und damit ist `docs/plan/planning/observations.md` ein struktureller Kollisions-Punkt für
parallel arbeitende Rolleninhaber.

**Der Beleg ist ein Vorfall, keine Hypothese.** Am 2026-09-03 liefen zwei Läufe desselben Slice
auf demselben Elternstand und schrieben dieselbe Datei; der Konflikt wurde von Hand aufgelöst:

```sh
git log --format='%H %P %s' -n 4    # 94f2552 und 787f7e8 tragen denselben Parent d96e9df
                                    # und dieselbe Message; 77c805a ist der Aufloesungs-Merge
```

Die Datei traf es nicht, aber die Bedingung ist dieselbe und für das Register **häufiger**: sie
wird von jeder Closure geschrieben — `git log --format=%H -- docs/plan/planning/observations.md
| wc -l` → **59** Commits.

**Die Kollisions-Einheit ist die Zeile, und sie ist hier riesig.** Ein Eintrag ist **eine**
Tabellenzeile; die längste misst **6 357** Zeichen:

```sh
grep '^| BEO-' docs/plan/planning/observations.md | awk '{print length($0)}' | sort -rn | head -1
```

Jede Beleg-Ergänzung an einem solchen Eintrag ändert genau diese eine Zeile — zwei Closures an
derselben Beobachtung kollidieren damit garantiert, und `git` hat keine feinere Auflösung
anzubieten. Die Ziel-Form legt jeden Beleg in eine **eigene** Datei
(`evidence/<vorgangs-id>.md`); damit kollidieren nur noch zwei Läufe, die denselben Beleg schreiben
— und *ein Vorgang zählt einmal* wird eine Eigenschaft des Dateisystems statt einer Disziplin.

**Die Ziel-Form ist die des Sprungs.** `v6.0.0` streicht
`templates/docs/plan/planning/observations.template.md` und legt
`templates/docs/plan/planning/observation.template.md` an — eine Vorlage je **Beobachtung**, mit
einem Verzeichnis `observations` unter `docs/plan/planning/` als Ablage, drei Dateien je Eintrag
(`observation.md` unveränderlich · `state.md` veränderlich · `evidence/<vorgangs-id>.md` je
Auftreten) und **ohne Zähler-Feld**: der Zähler ist die Zahl der Evidence-Dateien.

```sh
# am lokalen Kurs-Klon
git diff --name-status v5.18.0 v6.0.0 -- lab/templates/docs/plan/planning
git show v6.0.0:lab/regelwerk/modul-06-roadmap.md   # §Das Beobachtungs-Register
```

**Die Größe trägt hier nichts, und das steht so da statt als Analogie.** Das Vorbild
[`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)
teilte einen Speicher, der heute `cat harness/conventions.md harness/conventions/*.md | wc -c` →
**339 546** Zeichen misst; dieses Register misst `wc -c < docs/plan/planning/observations.md` →
**52 701** Zeichen bei `grep -c '^| BEO-' docs/plan/planning/observations.md` → **29** Einträgen.
Das Nachbar-Repo, das denselben Umzug bereits vollzogen hat, führt in der Ziel-Form **30**
Beobachtungen mit **90** Beleg-Dateien in **43 701** Zeichen
(`find /Development/d-check/docs/plan/planning/observations -name observation.md | wc -l`, dieselbe
Suche mit `-path '*/evidence/*.md'`, und `… -name '*.md' -exec cat {} + | wc -c`): dreimal so viele
Belege bei weniger Text. Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die Migration ist damit **billig**, nicht durch Größe **erzwungen** — der Treiber ist
die Kollisions-Einheit oben und die Pflicht des Sprungs.

**Was dieser Slice nicht entscheidet.** Ob `docs/plan/planning/observations.md` als Index-Datei
stehen bleibt, welche Gestalt die Kennung bekommt und ob der Umzug ein Commit ist oder zwei —
das sind drei Architect-Fragen, und sie stehen in
[slice-179](../done/slice-179-register-ortsfestigkeit-vor-dem-umzug.md), der diesem Slice
vorausgeht. Dieser Slice **vollzieht** die entschiedene Gestalt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **Die Ablage steht in der Ziel-Form.** Ein Verzeichnis `observations` unter
      `docs/plan/planning/` trägt je Beobachtung ein Verzeichnis nach `observation.template.md`
      des dann vendored Stands — `observation.md`, `state.md`, `evidence/` mit einer Datei je
      Auftreten — plus die `README.md`, die die Ablage auch leer sichtbar hält. **Die Gestalt ist
      entschieden:** [`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
      Festlegung 1 — die stehende Register-Datei entfällt ersatzlos, **keine** Index-Datei tritt
      an ihre Stelle; dieser Punkt setzt das um und trifft es nicht. **Kein Zähler-Feld bleibt
      stehen:** die Zahl der Evidence-Dateien **ist** der Zähler, und ein zweites Feld daneben
      wäre die Quelle, die die Form gerade abschafft. Das Kürzel-Segment des Ziel-Pfads
      `BEO-<KUERZEL>/<slug>` steht in derselben Entscheidung (Festlegung 3): `*` (gesamtes Repo)
      trägt `ALL`, und alle Einträge des Ausgangsstands führen diese Sub-Area. **Nachgetragen in
      der Review-Nacharbeit (HIGH-1):** Der erste Vollzugs-Commit hatte die fortlaufende Nummer
      `BEO-<NNN>` als Verzeichnisnamen belassen statt sie durch das Kürzel zu ersetzen — ein
      Reviewer-Fund, real bestätigt durch die von Hand vergebenen `BEO-040`/`BEO-041` beim
      slice-178-Merge. Alle 41 Verzeichnisse liegen jetzt unter `BEO-ALL/<slug>/`
      (`ls docs/plan/planning/observations/ | grep -c '^BEO-[0-9]'` → **0**,
      `ls docs/plan/planning/observations/BEO-ALL | wc -l` → **41**), reiner `git mv`, keine
      Slug-Kollision (41 eindeutige Slugs geprüft).
      Vollständigkeit gemessen statt behauptet: die Zahl der Verzeichnisse deckt
      `grep -c '^| BEO-' docs/plan/planning/observations.md` und die Zahl der Evidence-Dateien die
      Summe der Zähler-Spalte, beides am Ausgangsstand — der Ausgangsstand ist am Vollzugs-Commit
      nur noch über `git show <parent>:docs/plan/planning/observations.md` erreichbar, weil die
      Datei danach entfällt. Nachgemessen für **jeden** der 39 Einträge (nicht nur die Summe): Ein
      Vergleichs-Lauf hielt die Zähler-Spalte je `BEO-<NNN>` gegen die Zahl der Dateien unter dem
      jeweiligen `evidence/` — **39 von 39** identisch, **0** Abweichungen.
- [x] **Kein Verweis zeigt ins Leere.** Die lebenden Referenzen sind nachgezogen — Bezugsmenge
      `git grep -l 'observations\.md' -- '*.md' ':!.harness/baseline' | wc -l`
      (2026-09-05, am Start dieses Laufs: **112** Dateien, **615** Vorkommen mit `-o … | wc -l`;
      gewachsen gegenüber dem Planungsstand, keine Erwartungswerte,
      [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2). **Der Doppel-Anker-Mechanismus des Vorbilds hat hier keinen Gegenstand:** die
      Referenzen tragen keinen Eintrags-Anker, gemessen mit
      `git grep -o 'observations\.md#' -- '*.md' ':!.harness/baseline' | wc -l` → **0**. Welche
      Referenzen **nicht** nachgezogen werden, weil ihre Quelle eingefroren ist, ist entschieden
      und gemessen: **genau eine** —
      [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) trägt einen
      Markdown-Link auf die Register-Datei und steht auf `Accepted`. Ihr Ausgang ist ein viertes,
      namentlich geschnittenes `ignore-refs`-Paar
      ([`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
      Festlegung 2, samt Config-Kommentar und den zwei Belegläufen ihrer Folgepflicht 1) — beide
      Belegläufe in `.d-check.yml` gefahren: mit dem Eintrag fehlt der Befund, ohne ihn steht er.
      Alle übrigen betroffenen Dateien sind änderbar: lebende Artefakte sind nachgezogen (Pfad
      `observations.md` → `observations/README.md`), Zeitdokumente haben die Adresse verloren und
      den Text behalten
      ([`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4) — **mit einer
      benannten Ausnahme, die diese Zeile nicht erfüllt:** drei Einträge des Adaptions-Blocks
      ([`MR-041`](../../../../harness/conventions.md#mr-041),
      [`MR-047`](../../../../harness/conventions.md#mr-047),
      [`MR-048`](../../../../harness/conventions.md#mr-048)) trugen denselben toten Pfad als
      funktionierenden Markdown-Link. **Zweimal falsch, einmal richtig gezogen:** Die erste
      Review-Nacharbeit (`d3490fb`) hat sie im Implementer-Kontext nachgezogen mit der Begründung
      „reiner Pfad-Nachzug wegen des Moves zählt nicht als Architect-Entscheidung" — eine Lesart,
      die vom Koordinator (in Architect-Rolle) stammte und die Runde-2-Reviewer als HIGH
      widerlegt hat: [`AGENTS.md`](../../../../AGENTS.md) §3.8 sagt „Gebunden ist das **Schreiben**"
      ohne Move-Ausnahme, und [`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
      sagt für genau diesen Verweis „Das ist ein Architect-Commit … und liegt damit neben dem
      Migrations-Commit". Revertiert (`66a49e9`) und als eigener Architect-Commit neu gezogen
      (`2826fdb`). **Ein zweiter, davon unabhängiger toter Verweis (HIGH-4)** stand in
      `.harness/skills/reviewer.md:111` (Reviewer-Eigentum nach
      [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1)
      — der erste Vollzugs-Commit hatte ihn fälschlich im Implementer-Kontext repariert
      (Rollen-Übergriff), die Review-Nacharbeit hat ihn auf den Vor-Migrations-Wortlaut
      zurückgesetzt, und die Reviewer-Rolle selbst hat die inhaltliche Korrektur nachgezogen
      (`278248f`). Belegt durch `make docs-check`: **0** verbleibende `target-missing`-Befunde.
      Der Punkt gilt jetzt vollständig erfüllt, beide Rollen-Übergriffe sind durch je einen
      passend zugeschriebenen Commit ersetzt, nicht nur zurückgenommen.
- [x] `make gates` grün — `make gates` → EXIT 0, `d-check: 776 Datei(en) geprüft, 0 Befund(e)`.
      Die geprüfte Datei-Zahl wandert mit dem Bestand und ist **kein** Erwartungswert
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2); beobachtbar ist die Null dahinter. Reproduzierbar ist der Lauf nur über einem
      Baum **ohne** fremden Agenten-Worktree — die Bedingung dafür ist rein operativ und steht als
      offener Punkt in §6.
      Alle anderen Gates dieses Laufs sind einzeln grün geprüft (`baseline-verify`, `lint`,
      `build`, `test` inkl. aller 218 bats-Fälle, `shell-lint`, `ci-lint`, `comment-claims`,
      `host-bin`, `span-check`). **Korrektur einer eigenen Fehleinschätzung:** Eine frühere
      Fassung dieser Zeile behauptete, die zuvor gemeldete Verunreinigung durch ein fremdes
      Orchestrierungs-Artefakt (`.claude/worktrees/`, §6) sei „nicht mehr reproduzierbar", weil
      das Verzeichnis inzwischen `.gitignore`t ist (`ac801bb`). Der Runde-2-Reviewer hat das
      widerlegt: `.gitignore` ändert die von `docs-check` gescannte Fläche nicht — eine Probe-Datei
      unter `.claude/worktrees/` färbt den Sensor weiterhin rot, ignoriert oder nicht. Der
      tatsächliche Schutz ist rein operativ (kein Worktree beim Gate-Lauf vorhanden), keine
      strukturelle Gate-Eigenschaft — eine echte Behebung bräuchte einen `.d-check.yml
      scan.ignore`-Eintrag und damit eine eigene ADR nach [`AGENTS.md`](../../../../AGENTS.md)
      §3.5. Das bleibt eine benannte, nicht behobene Lücke (§6).
- [x] Doku-Update: [welle-15](../welle-15-re-baseline.md) §4 führt diesen Slice; jede Quelle, die
      die Register-**Form** beschreibt statt nur auf sie zu zeigen, ist nachgezogen oder als
      Übergabe benannt (§6). Ein öffentlicher Vertrag ist nicht berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register fortgeschrieben — neuer Eintrag oder ein weiterer Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `observations` unter `docs/plan/planning/` | neu | die Ablage, je Beobachtung ein Verzeichnis aus der vendored Vorlage |
| `docs/plan/planning/observations.md` | refactor | geht ersatzlos in der Ablage auf — keine Index-Datei bleibt stehen ([`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Festlegung 1) |
| lebende Verweise auf die alte Datei | update | Bezugsmenge und Kommando in DoD 2 |

**Der Commit-Zuschnitt ist entschieden: ein Commit.**
[`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
Festlegung 4 — [`AGENTS.md`](../../../../AGENTS.md) §3.3 greift nicht, weil ihr Gegenstand fehlt:
Der Vorgang ist eine Zerlegung ohne Move. Die Messung, dass es **keine** grüne Zwischenteilung
gibt, ist in diesem Repo gefahren und nicht vom Nachbarn übernommen (`355` Befunde über `75`
Dateien für den Zustand *alte Datei fort, Ablage und Verweise noch nicht da*). Der zweite Beleg
ist von **diesem** Lauf vorzulegen: `git diff-tree -r --name-status -M` über dem
Migrations-Commit weist keine `R`-Zeile aus. Weist sie eine aus, trifft die Prämisse von §3.3 doch
zu, und der Vorgang wird geteilt. Die Kürzel-Spalte in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) liegt
**neben** diesem Commit, nicht in ihm — sie ist ein Architect-Commit
([`AGENTS.md`](../../../../AGENTS.md) §3.8, [`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
Folgepflicht 2).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`), zwei Bedingungen:

1. **Der vendored Baum trägt die Ziel-Form** — `make baseline-verify` meldet `v6.0.0 OK`. Die
   Bedingung nennt **kein** Slice, weil der tauschende Slice aus dem Katalog in
   [slice-176](../done/slice-176-inventur-vor-dem-schnitt-v600.md) §9 hervorgeht und heute nicht
   existiert; eine Kennung hier behauptete eine Datei, die es nicht gibt. Der Grund ist tragend,
   nicht ordnend: Vor dem Tausch ist `v5.18.0` der Ist-Maßstab
   ([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2), und die
   Vorlage, aus der die Ablage per `cp` entsteht, liegt netzlos erst danach vor.
2. **[slice-179](../done/slice-179-register-ortsfestigkeit-vor-dem-umzug.md) liegt in `done/`, und
   die dort entstandene ADR steht auf `Accepted`.** Eine `Proposed`-ADR bindet den
   Durchgang nicht. Der Grund ist tragend:
   [`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 4
   verlangt die Entscheidung **vor** dem Move, und ohne das Kürzel-Segment aus jener Entscheidung
   hat der Ziel-Pfad `BEO-<KUERZEL>/<slug>` kein erstes Segment.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der Verweis-Nachzug nicht mechanisch
  läuft — `make slice-mv` deckt die Slice-Adressen, nicht diese —, und die 93 Dateien einzeln
  gelesen werden müssen. Dann trennt der Schnitt Ablage (Liefer-Punkt 1) und Verweis-Nachzug
  (Liefer-Punkt 2) in zwei Slices.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Umsetzung eine Frage aufwirft, die
  [slice-179](../done/slice-179-register-ortsfestigkeit-vor-dem-umzug.md) nicht entschieden hat.
  Sie geht dorthin zurück, nicht in diesen Lauf.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; `make docs-check` ohne Befund über der neuen Ablage; Closure-Notiz mit
Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Ein Verweis-Nachzug über 93 Dateien bricht etwas, das kein Gate sieht** (`BEO-003`, 5×,
  **verkörpert** in `make slice-mv`). Dessen Deckung gilt Slice-Adressen; für diese Datei gibt es
  keinen Träger, und die präfixlose Form bricht in beide Richtungen. `make docs-check` fängt die
  Link- und Codepath-Hälfte, nicht die Inline-Code-Hälfte (`BEO-025`). — **Ausgang: eingetreten,
  Folge-Slice [slice-186](../open/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md).** Der
  Nachzug lief manuell (gezielte `sed`-Ersetzungen je Klasse: Lebend → Pfad umgehängt,
  Zeitdokument → Adresse verloren) und iterativ gegen `make docs-check` — und genau darin liegt der
  Eintritt: Die Inline-Code-Hälfte, die dieselbe Zeile als ungedeckt benennt, hat er übersehen. Der
  Beleg steht zwei Einträge weiter unten (der `awk`-Aufruf in [slice-181] §8), gefunden von einem
  Reviewer und nicht von einem Sensor. `make slice-mv` ist an dieser Stelle **nicht** einschlägig —
  der Vollzugs-Commit zeigt keine `R`-Zeile in `git diff-tree --name-status -M` (Plan §3) —, aber
  das beantwortet eine andere Frage als die, die dieses Risiko stellt: Ob der Nachzug etwas
  gebrochen hat, hängt nicht daran, welches Werkzeug ihn hätte fahren können.
- **Die Form-Beschreibung steht an mehreren Orten und zieht nicht mit** (`BEO-009`, 9×). Der
  Kopftext des Registers, die drei Anweisungssätze unter `.claude/commands/` und ihre emittierten
  Gegenstücke beschreiben die heutige Tabellen-Form — dazu die Vorlagen-Zeile *„Beobachtungs-Register
  (`../observations.md`) fortgeschrieben"*, die in **jedem** offenen Slice-Plan steht. Wer die
  Anweisungssätze schreiben darf, ist die offene Frage aus `BEO-007`. — **Ausgang: weiter offen.**
  Unverändert gegenüber dem migrierten Registerstand (`BEO-009`/`BEO-007`); die **Grenze zwischen
  diesem Slice und [slice-184](../open/slice-184-register-form-im-bestand-nachziehen.md) ist real
  gemessen statt behauptet** (Review-Nacharbeit, Review-Fund MEDIUM-1: die beiden Pläne wiesen sich
  dieselbe Teilmenge wechselseitig zu). **Was dieser Slice trägt:** die bare Adresse
  `observations.md` → `observations/README.md`, überall dort, wo sie **unabhängig** von der
  Vorlagen-Zeile auftritt — die drei Anweisungssätze unter `.claude/commands/` und ihre emittierten
  Gegenstücke (sechs Dateien, `git grep -l 'observations\.md' -- .claude/commands
  internal/emit/templates/commands`, alle sechs jetzt auf `observations/README.md` gezogen), dazu
  jede Markdown-Link-Form repo-weit (`LOW-1`, Label nachgezogen). **Was [slice-184] trägt:** genau
  die Fälle, in denen Adresse und Form **dieselbe Zeichenkette** sind und sich nicht trennen lassen
  — die Vorlagen-Zeile *„Beobachtungs-Register (`../observations.md`) fortgeschrieben"* selbst, in
  jedem offenen/nächsten/laufenden Slice-Plan, in dem sie steht: Ihre Adresse ist mit ihrer
  Form-Aussage (*neue `BEO-<NNN>` oder Zähler +1*) verwoben, und ein Nachzug, der nur die Adresse
  träfe, verschöbe die Form-Korrektur ohne sie zu leisten. Diese Grenze steht jetzt symmetrisch in
  beiden Plänen.
- **Die Zwischen-Zustands-Zusage ist nicht bewiesen, sondern hergeleitet.** Dass zwei Closures an
  verschiedenen Beobachtungen nicht mehr kollidieren, folgt aus der Datei-Trennung; ein
  Gegenbeispiel ist hier **nicht** rot gesehen ([`AGENTS.md`](../../../../AGENTS.md) §3.6), und kein
  Sensor misst Merge-Verhalten. Der Slice sagt darum die **Eigenschaft der Ablage** zu, nicht ein
  Ausbleiben von Konflikten. — **Ausgang: weiter offen.** Unverändert seit der Planung — kein Sensor
  für Merge-Verhalten existiert und wurde in diesem Lauf auch nicht gebaut (außerhalb des
  Liefer-Umfangs). Kandidat für das Beobachtungs-Register bei der Closure.
- **Der Umzug überträgt einen Inhalt, den er zugleich zerlegt.** Aus einer Tabellenzelle werden
  `observation.md`, `state.md` und je Beleg eine Datei; die heutigen Zellen mischen Identität,
  Stand und Beleg-Prosa in einem Absatz. Die Zerlegung ist ein **Urteil** je Eintrag, kein
  Formatwechsel — 29 Einträge mit **58** Belegen
  (`awk -F'|' '/^\| BEO-/{gsub(/[^0-9]/,"",$5); s+=$5} END{print s}' docs/plan/planning/observations.md`,
  kein Erwartungswert). Reicht sie über eine Review-Sitzung hinaus, greift die erste Rückführung
  aus §4. — **Ausgang: eingetreten, ohne die Rückführung auszulösen.** Der Bestand wuchs zwischen
  Planung und Vollzug auf 39 Einträge mit 82 Belegen; die Zerlegung ist vollzogen und **maschinell
  nachgeprüft** (Zähler-Deckung 39/39 gegen den Ausgangsstand, siehe DoD 1) statt nur behauptet. Ob
  die Menge eine Review-Sitzung überschreitet, ist eine Reviewer-Entscheidung und wird hier nicht
  vorweggenommen; die Rückführung bleibt dem Reviewer/Planner vorbehalten, falls sie doch greift.
- **Drei Architect-Zeilen trugen nach dem Wegfall einen toten Verweis** — im ersten Vollzugs-Commit
  gefunden, kein Eintrag im Beobachtungs-Register zum Planungszeitpunkt.
  [`MR-041`](../../../../harness/conventions.md#mr-041),
  [`MR-047`](../../../../harness/conventions.md#mr-047) und
  [`MR-048`](../../../../harness/conventions.md#mr-048) verlinkten `BEO-008` über den alten Pfad;
  alle drei gehören zum Adaptions-Block und sind damit nach [`AGENTS.md`](../../../../AGENTS.md)
  §3.8 Architect-Eigentum für ihren **Inhalt**. — **Ausgang: entfallen**, und der Weg dahin führte
  über einen eigenen Verstoß derselben Regel. Alle drei Zeilen zeigen auf
  `BEO-ALL/adaptions-achse-1-kurzschluss/observation.md`, `make docs-check` meldet für diese Klasse
  **0** Befunde, und kein fünftes `ignore-refs`-Paar ist nötig. **Gezogen hat sie ein
  Architect-Commit** (`2826fdb`), der ausschließlich Architect-Artefakte berührt — die drei
  Eintrags-Dateien und sonst nichts (`git show --stat 2826fdb`). **Der erste Versuch war selbst ein
  §3.8-Verstoß, nicht bloß eine unbelegte Behauptung:** `d3490fb` schrieb dieselbe Änderung im
  Implementer-Kontext und stützte sich auf die Lesart *„reiner Pfad-Nachzug wegen des Moves zählt
  nicht als Architect-Entscheidung"*. Diese Lesart hat keine Quelle —
  [`AGENTS.md`](../../../../AGENTS.md) §3.8 sagt *„Gebunden ist das **Schreiben**"* ohne
  Move-Ausnahme, und [`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  sagt für genau diesen Verweis *„Das ist ein Architect-Commit … und liegt damit neben dem
  Migrations-Commit"*. Der Commit ist revertiert (`66a49e9`), die Änderung in der richtigen Rolle
  wiederholt. Sie steht hier, weil eine frühere Fassung dieser Zeile die widerlegte Lesart als
  Begründung führte; ein Folgelauf, der sie liest, würde sich auf eine Ausnahme berufen, die keine
  Quelle deckt.
- **Ein Reviewer-eigener Verweis wurde im Implementer-Kontext geändert** (`HIGH-4`, neu, während der
  Review-Nacharbeit gefunden). `.harness/skills/reviewer.md:111` verlinkt die Register-Datei; der
  erste Vollzugs-Commit hatte die Zeile auf `observations/README.md` korrigiert, obwohl
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 diese
  Datei ausdrücklich der **Reviewer**-Rolle zuweist — ein Rollen-Übergriff, während derselbe Commit
  die drei MR-Zeilen aus demselben Grund unangetastet ließ. — **Ausgang: entfallen.** Der benannte
  Träger hat gehandelt: Die **Reviewer**-Rolle hat die inhaltliche Korrektur in ihrem eigenen
  Kontext vorgenommen (`278248f` — eine Datei, eine Zeile, Message *„Rolle Reviewer: …"*, mit
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 als
  Grundlage). Der Zeiger steht in der Verzeichnis-Form, und `make docs-check` meldet **0**
  `target-missing`-Befunde. Damit ist auch der Rollen-Übergriff des ersten Vollzugs-Commits nicht
  nur zurückgenommen, sondern durch einen passend zugeschriebenen Commit **ersetzt** — die Sequenz
  mit Übergabe-Artefakt, die Baseline-Regelwerk `modul-08-agentenrollen.md` verlangt.
- **Historische Prosa-Zitate der alten `BEO-<NNN>`-Nummer lösen nach dem Umzug auf `BEO-ALL` nicht
  mehr auf** — neu, während der Review-Nacharbeit zu HIGH-1 gefunden. Vorbestehende lebende Dateien
  außerhalb von `observations/` (`welle-15-re-baseline.md`, `roadmap.md`, offene/nächste Slice-Pläne,
  `harness/conventions/*.md` außer den drei oben genannten MR-Einträgen) zitieren einzelne
  Beobachtungen weiter unter ihrer alten Nummer (`BEO-010`, `BEO-018` etc.) — reine Kennungs-Prosa,
  kein Pfad, darum kein `docs-check`-Befund, aber ein Leser, der die alte Nummer als Verzeichnis
  sucht, findet sie nicht mehr. — **Ausgang: eingetreten, Folge-Slice
  [slice-186](../open/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md).** Nicht prognostiziert,
  sondern in diesem Diff manifest: `9292a08` hat die Zitate tot gemacht. **Der Umfang ist jetzt
  gemessen statt geschätzt** (2026-09-05, keine Erwartungswerte,
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2):

  ```sh
  git grep -l 'BEO-[0-9]' -- '*.md' ':!.harness/baseline' ':!docs/reviews' \
    ':!docs/plan/planning/done' ':!docs/plan/planning/observations' | wc -l          # 23 Dateien
  git grep -o 'BEO-[0-9][0-9][0-9]' -- '*.md' ':!.harness/baseline' ':!docs/reviews' \
    ':!docs/plan/planning/done' ':!docs/plan/planning/observations' | wc -l          # 134 Vorkommen
  git grep -c 'BEO-[0-9]' -- 'docs/plan/planning/observations' \
    | awk -F: '{s+=$NF} END{print s+0}'                                              #  7 innerhalb
  ```

  Die **7** innerhalb der Ablage sind der schärfere Teil: sechs liegen in `evidence/`-Dateien
  (*unveränderlich ab Merge*), eines in `BEO-ALL/regel-delta-zaehlt-herkunfts-kommentar-mit/observation.md`
  (*unveränderlich ab Anlage*) — dessen Zitat zeigt auf ein Ziel, das seit dem Umzug nur noch über
  `git ls-tree 9292a08^` auflöst. **Kein Carveout**, weil kein Gate rot steht: Die Klasse hat
  keinen Wächter, `make docs-check` bleibt über ihr grün, und ein Carveout schaltet einen roten
  Gate-Status auf Trigger, den es hier nicht gibt. **Nicht [slice-184]**, und die Grenze ist
  textlich gemessen statt behauptet: Jener Slice trägt die **Form-Sprache** — den Platzhalter
  `BEO-<NNN>`, *Registerzeile*, *Zähler erhöhen* —, dieser Befund die **Identität** einer
  konkreten Beobachtung; `printf 'BEO-<NNN>\n' | grep -c 'BEO-[0-9][0-9][0-9]'` → **0**, die zwei
  Mengen schneiden sich nicht. Ein vierter Liefer-Punkt an [slice-184] hätte ihn zudem über die
  Drei-Punkte-Grenze von Modul 5 gehoben.
- **Ein Kommando in einem lebenden Plan liest die abgeschaffte Tabellenform** — neu, vom
  Runde-2-Reviewer gefunden. Der Sichtungs-Schritt in
  [slice-181](../open/slice-181-grenzen-liste-vollstaendig-oder-fail-closed.md) §8 belegt sich mit
  einem `awk -F'|'`-Aufruf über die entfallene Register-Datei und schneidet auf deren
  Tabellenspalten. Die Stelle liegt **innerhalb** der Hälfte, die dieser Slice für sich reklamiert
  — die bare Adresse überall dort, wo sie unabhängig von der Vorlagen-Zeile auftritt; die zwei
  Vorlagen-Zeilen derselben Datei sind [slice-184](../open/slice-184-register-form-im-bestand-nachziehen.md)
  zugeschlagen. **Ein reiner Pfad-Nachzug träfe es nicht:** das Kommando liefe danach lautlos leer,
  statt zu fehlen — die Feldstruktur gibt es in der Ziel-Form ebenso wenig wie die Datei.
  **Und kein Gate sieht es:** der Pfad steckt in einem Inline-Code-Span, der ein ganzes
  Shell-Kommando umfasst, und erscheint auch im kontrafaktischen `d-check`-Lauf **ohne** das
  siebte `ignore-refs`-Paar nicht unter den Befunden. — **Ausgang: eingetreten, Folge-Slice
  [slice-186](../open/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md)**, dort Liefer-Punkt
  3. **Nicht `weiter offen` mit [slice-181] als Träger:** Jener Slice hat einen anderen Gegenstand
  (eine Grenzen-Liste neben einem Ausdruck), und ihm eine Nacharbeit zuzuweisen, die seine DoD
  nicht führt, wäre ein Ausgang, der seinen Träger nur benennt — genau die Klasse, die der
  Runde-2-Reviewer an diesem §6 beanstandet hat.
- **Ein fremdes Orchestrierungs-Artefakt im Arbeitsbaum verfälscht Gate-Läufe** — kein Risiko dieses
  Slice-Inhalts, aber während der Verifikation gefunden und rot-dann-grün belegt
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6): ein unversionierter, ungeignorter Git-Worktree unter
  `.claude/worktrees/agent-a7cc0039bb43f2cee/` (eine volle zweite Baumkopie einer anderen,
  gleichzeitig laufenden Sitzung) liegt im von `.d-check.yml` gescannten Wurzelverzeichnis und
  verdoppelt Treffer für `make docs-check` (5484 zusätzliche Befunde, gemessen mit/ohne die
  ausgeschlossene Teilmenge) **und** löst über eine `pipefail`+`SIGPIPE`-Interaktion in
  `harness/tools/comment-claims.sh` einen falschen `bats`-Fehlschlag aus (Test *„Behauptung MIT
  Sensor-Nennung: gruen"*, `test/comment-claims.bats:27`): `find … | xargs … grep -lE … | grep -q .`
  liefert bei **zwei** Treffern (Original + Worktree-Duplikat von `internal/gen/gen_test.go`)
  reproduzierbar `NOT FOUND`, bei **einem** Treffer (Worktree-Pfad aus `find` ausgeschlossen)
  zuverlässig `FOUND` — beide Zustände gegeneinander gemessen, nicht nur behauptet. — **Ausgang:
  weiter offen**, außerhalb des Eigentums dieses Slice: Weder die Worktree-Bereinigung noch eine
  `.gitignore`-Ergänzung für `.claude/worktrees/` gehören zum Liefer-Umfang; die Beobachtung ist ein
  Kandidat für das Beobachtungs-Register (Sub-Area `harness/tools/`, Fund: ein zweiter Treffer kann
  eine `pipefail`-Pipeline in `comment-claims.sh` durch SIGPIPE zum Fehlschlag bringen, unabhängig
  von seiner Ursache).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (eine vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register:** <…> — dieser Slice schreibt seinen eigenen Eintrag bereits in die
  **neue** Ablage; der Übergang ist damit an seiner ersten Benutzung geprüft.
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** dieses Repo führt Wellen-Betrieb — sie prüft die Closure von
  [welle-15](../welle-15-re-baseline.md).

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die einzige Sub-Area, die
die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) für
das Planning-Layout führt; `harness/tools/` und `.codex/` sind nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Das [Register](../observations/README.md) ist vollständig
durchgegangen. **Jede** Zeile trägt `*` (gesamtes Repo) — die Spalte unterscheidet in diesem Repo
nichts (`BEO-004`). Fünf Zeilen berühren diesen Slice mit ihrem Zähler-Stand:

- `BEO-003` (5×, **verkörpert**) — *Verweise brechen beim Ortswechsel*. Die verkörperte Deckung
  gilt Slice-Adressen; diese Datei hat keinen Träger. Steht als Risiko in §6.
- `BEO-009` (9×, **geplant**) — *eine Zusage neben der geänderten Ableitung bleibt stehen*. Die
  Form-Beschreibung des Registers steht an mehreren Orten. Steht als Risiko in §6.
- `BEO-017` (2×) — *ein vorgeschriebener Ortswechsel macht eine Adresse in einem eingefrorenen
  Artefakt tot*. **Dieser Umzug ist ein Auftreten der Klasse**; sein Ausgang steht nicht hier,
  sondern in [slice-179](../done/slice-179-register-ortsfestigkeit-vor-dem-umzug.md), der ihm
  deshalb vorausgeht.
- `BEO-025` (2×) — *eine Zusage nennt einen Sensor, der die zugesagte Form nicht sieht*. Bindet die
  Formulierung von DoD 2: `make docs-check` deckt Link und Codepath, nicht Inline-Code.
- `BEO-002` (1×) — *eine Registerzeile hat keine Spalte für einen Träger*. Die Ziel-Form trennt
  `observation.md`, `state.md` und `evidence/`; ob sie diese Lücke schließt, ist bei der Closure zu
  prüfen statt anzunehmen.

Keine erreicht mit diesem Slice 3×.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.

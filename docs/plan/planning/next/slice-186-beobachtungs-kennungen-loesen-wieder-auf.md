# Slice slice-186: Jede zitierte Beobachtungs-Kennung löst wieder auf

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-15](../welle-15-re-baseline.md) — **Mitglied aus Gleichzeitigkeit, nicht aus
Nähe**, dieselbe Begründung wie bei
[slice-184](../done/slice-184-register-form-im-bestand-nachziehen.md). Der Umzug dieser Welle hat die
fortlaufende Nummer abgeschafft; seither zitieren **23** lebende Dateien eine Kennung, die
nirgends mehr auflöst (§1, mit Kommando). Ein Ausgang in `open/` wäre hier gerade **kein**
verbuchter Ausgang im Sinne des Welle-Ziels *„statt einzeln als Nachzügler zurückzukommen"* — der
Nachzügler wäre mit dem Umzug schon da. **Der Unterschied zu
[slice-183](slice-183-ausloeser-der-wellenlosen-archivierung.md)**, der aus demselben Katalog kommt
und ausdrücklich **draußen** bleibt: Dort ist nichts gebrochen, dort wird eine offene Frage
entschieden, und die Datei in `open/` ist der verbuchte Ausgang.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die
abgeschaffte Kennungs-Form kommt aus dem auf einen Tag gepinnten Baum),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein
Modul sieht diese Klasse — die DoD darf keinen Sensor als Beleg anführen, der sie nicht prüft),
[`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(die entschiedene Kennungs-Gestalt `BEO-<KUERZEL>/<slug>`, Festlegung 3),
[`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) (Festlegung 4 zieht die Grenze zu den
Zeitdokumenten: Text bleibt, Adresse fällt),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando).

**Berührte Spec-Stellen:** `—`. Der Slice zieht Kennungs-Zitate nach; er schreibt keine
Spec-Stelle.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-05.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Kein lebendes Artefakt dieses Repos zitiert eine Beobachtung unter einer Kennung, die nicht mehr
auflöst.**

`v6.0.0` schafft die fortlaufende Nummer ab — *„Eine fortlaufende Nummer gibt es nicht mehr"* —
und setzt an ihre Stelle den Pfad `BEO-<KUERZEL>/<slug>`
([`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
Festlegung 3, Katalog-Position **P-02** in
[slice-176](../done/slice-176-inventur-vor-dem-schnitt-v600.md) §9).
[slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) hat die
**Verzeichnisse** gezogen; die **Zitate** der alten Nummer stehen weiter. Ein Leser, der eine
solche Nummer nachschlägt, findet nichts — sie löst nur noch über den Elternstand des Umzugs auf.

**Dieser Plan führt selbst keine dreistellige Nummer**, und das ist Absicht statt Zufall: Er liegt
in der Bezugsmenge unten, und ein Beispiel im Fließtext würde die Zahl erhöhen, die die DoD auf
null bringen soll. Wo dieser Text die abgeschaffte Gestalt zeigen muss, zeigt er sie als
Platzhalter `BEO-<NNN>`.

**Der Bestand ist gemessen, nicht geschätzt** (2026-09-05):

```sh
git grep -l 'BEO-[0-9]' -- '*.md' ':!.harness/baseline' ':!docs/reviews' \
  ':!docs/plan/planning/done' ':!docs/plan/planning/observations' | wc -l          # 23 Dateien
git grep -o 'BEO-[0-9][0-9][0-9]' -- '*.md' ':!.harness/baseline' ':!docs/reviews' \
  ':!docs/plan/planning/done' ':!docs/plan/planning/observations' | wc -l          # 134 Vorkommen
git grep -c 'BEO-[0-9]' -- 'docs/plan/planning/observations' \
  | awk -F: '{s+=$NF} END{print s+0}'                                              #  7 innerhalb
git grep -o '\[`BEO-[0-9]*`\]([^)]*observations/README\.md)' -- '*.md' \
  ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' | wc -l       # 46 Links
git grep -o 'observations/BEO-ALL/[a-z0-9-]*/observation\.md' -- '*.md' \
  ':!.harness/baseline' | wc -l                                                    # 15 in Zielform
```

Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — jede Zahl wandert mit jedem neu geschnittenen Plan und jeder Closure. Die **23**
verteilen sich auf `docs/plan/planning/open/` **13**, `harness/conventions/` **3**,
`docs/plan/adr/` **2**, `docs/plan/planning/in-progress/` **2**, `harness/` **1**,
`docs/plan/planning/` **1**, `.claude/commands/` **1** (dasselbe Kommando mit
`| xargs -n1 dirname | sort | uniq -c`).

**Die 46 sind die zweite Hälfte desselben Gegenstands.** `observations/README.md` §Zwei
Verweis-Formen entscheidet: *„Ein Verweis auf **eine konkrete Beobachtung** — ihre Bezeichnung, ihr
Stand, ihr Zähler — zeigt auf deren eigene `observation.md`"*. **46** lebende Links tragen eine
konkrete Kennung als Label und zeigen auf die Wurzel; **15** stehen in der entschiedenen Form. Das
Label nennt dabei eine Identität, die es nicht mehr gibt — dieselbe Sache wie die Prosa-Zitate,
nur in Link-Gestalt.

**Von den zwei Zahlen misst nur die erste den Rückstand.** Die **15** wächst mit jedem Plan, der
die entschiedene Form von Anfang an benutzt — die Pläne dieses Slice tun das —, und sagt darum
nichts darüber, wieviel Arbeit offen ist. Der Liefergegenstand hängt allein an der **46**: sie
trifft nach diesem Slice null, die 15 ist frei beweglich.

**Die Grenze zu den zwei Nachbarn ist gezogen, nicht behauptet — und die drei Mengen sind textlich
disjunkt.** Der Review-Fund, der die zirkuläre Zuweisung zwischen den ersten beiden auflöste,
verlangt sie in **jedem** beteiligten Plan; hier steht sie zum dritten Mal symmetrisch:

| Träger | Gegenstand | Muster |
|---|---|---|
| [slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) | die bare **Adresse** der Ablage | `observations.md` → `observations/README.md` |
| [slice-184](../done/slice-184-register-form-im-bestand-nachziehen.md) | die **Form-Sprache** und ihre Anweisung | `BEO-<NNN>` als Platzhalter · *Registerzeile* · *Zähler erhöhen* · die Vorlagen-Zeile |
| **hier** | die **Kennung als Identität** einer konkreten Beobachtung | eine dreistellige Zahl an der Stelle des Platzhalters |

Die Disjunktheit ist geprüft und nicht angenommen: `printf 'BEO-<NNN>\n' | grep -c 'BEO-[0-9][0-9][0-9]'`
→ **0**. Der Platzhalter mit den spitzen Klammern fällt nicht in die Menge dieses Slice, und die
Vorlagen-Zeile trägt keine dreistellige Zahl.

**Die Abbildung Nummer → Slug ist verlustfrei erreichbar** und damit ist der Nachzug mechanisch
statt raterisch — der Elternstand des Umzugs trägt beide Segmente in einem Pfad:

```sh
git ls-tree -d --name-only 9292a08^ docs/plan/planning/observations/ | wc -l   # 41 Paare Nummer/Slug
```

**Was dieser Slice nicht entscheidet.** Ob eine Datei, die die Ablage-Regel als **unveränderlich**
führt — `observation.md` ab Anlage, `evidence/<vorgangs-id>.md` ab Merge —, für einen
Kennungs-Nachzug geöffnet werden darf. Das ist Liefer-Punkt 2, und sein Ausgang kann eine
Architect-Entscheidung sein statt einer Ersetzung (§4, zweite Rückführung).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Die Kennungs-Zitate außerhalb der Ablage nennen die Pfad-Form.** Jedes Vorkommen einer
      dreistelligen `BEO`-Nummer in einem lebenden Artefakt nennt stattdessen `BEO-ALL/<slug>`;
      wo das Zitat ein Markdown-Link ist, folgt sein Ziel der entschiedenen Verweis-Konvention
      (`observations/README.md` §Zwei Verweis-Formen: konkrete Beobachtung → ihre eigene
      `observation.md`). Vollständigkeit gemessen statt behauptet: das zweite Kommando aus §1
      trifft danach **null**, das vierte ebenfalls. **Zeitdokumente bleiben unangetastet** —
      `docs/plan/planning/done/` und `docs/reviews/` sind Chronik von Beruf
      ([`AGENTS.md`](../../../../AGENTS.md) §3.7,
      [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4); sie stehen
      darum in der Bezugsmenge von §1 ausgeschlossen und nicht bloß unbearbeitet.
- [ ] **Die sieben Vorkommen innerhalb der Ablage tragen einen benannten Ausgang** — entweder
      nachgezogen, oder ausdrücklich stehengelassen mit der Regel, die das trägt. Sechs liegen in
      `evidence/`-Dateien (*unveränderlich ab Merge*), eines in einer `observation.md`
      (*unveränderlich ab Anlage*, für **Bezeichnung und Sub-Area** — die zitierende Zeile ist
      keines von beiden, und genau diese Unterscheidung ist zu treffen statt anzunehmen). Der
      Ausgang steht im Plan, nicht nur im Commit.
- [ ] **Der Sichtungs-Schritt von
      [slice-181](slice-181-grenzen-liste-vollstaendig-oder-fail-closed.md) §8 liest keine
      abgeschaffte Struktur mehr.** Sein Beleg-Kommando schneidet mit `awk -F'|'` auf die
      Tabellenspalten des entfallenen Trägers; ein reiner Pfad-Nachzug ergäbe ein Kommando, das
      lautlos leer liefert — der Ersatz zählt Evidence-Dateien und liest `state.md`.
      **Kein Gate sieht das:** der Pfad steckt in einem Inline-Code-Span, der ein ganzes
      Shell-Kommando umfasst, und `make docs-check` bleibt darüber grün.
- [ ] `make gates` grün.
- [ ] Doku-Update: [welle-15](../welle-15-re-baseline.md) §4 führt diesen Slice. Ein öffentlicher
      Vertrag ist **nicht** berührt — der emittierte Baum führt keine `BEO`-Kennung dieses Repos
      (`git grep -o 'BEO-[0-9][0-9][0-9]' -- internal/emit/templates | wc -l` → **0**; die
      `-c`-Form taugt hier nicht, sie schweigt bei null Treffern statt eine Null auszugeben).
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
| Slice-Pläne in `open/` und `in-progress/` | update | 15 der 23 Dateien; Bezugsmenge und Kommando in §1 |
| [`harness/conventions/`](../../../../harness/conventions/) | update | drei Einträge — **Architect-Artefakt** ([`AGENTS.md`](../../../../AGENTS.md) §3.8), eigener Commit, eigene Rolle |
| [`docs/plan/adr/`](../../adr/) | update **oder** *keine*, je nach Status | zwei Dateien, zwölf Vorkommen — die `Accepted`-Hälfte ist nach §3.4 eingefroren, die `Proposed`-Hälfte nicht; steht als Risiko in §6 |
| [`harness/README.md`](../../../../harness/README.md), [`.claude/commands/`](../../../../.claude/commands/), [roadmap](../in-progress/roadmap.md), [welle-15](../welle-15-re-baseline.md) | update | je ein Vorkommen; der Anweisungssatz gehört seiner ausführenden Rolle ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)) |
| `docs/plan/planning/observations/` | update oder *keine* | Liefer-Punkt 2 — die Entscheidung steht vor der Änderung |
| [slice-181](slice-181-grenzen-liste-vollstaendig-oder-fail-closed.md) §8 | update | Liefer-Punkt 3 — Kommando statt Zitat |

**Der Commit-Zuschnitt zerfällt nach Rolle, nicht nach Datei-Menge.** Die drei Einträge unter
`harness/conventions/` und die Anweisungssatz-Dateien gehören anderen Rollen als der Plan-Bestand;
die Präzedenz ist in diesem Repo gemessen und teuer bezahlt — derselbe Nachzug wurde an derselben
Stelle einmal im falschen Kontext geschrieben, revertiert und als eigener Architect-Commit
wiederholt ([slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) §6).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) liegt in `done/`.
Der Grund ist **tragend**, nicht ordnend: Seine Plan-Datei ist selbst eine der gemessenen 23
(`git grep -l 'BEO-[0-9]' -- 'docs/plan/planning/in-progress/*.md'` → `roadmap.md` und jene
Datei), und mit dem `git mv` wird sie ein Zeitdokument, das nach
[`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 den Text behält und die
Adresse verliert. Ein Nachzug davor zöge eine Datei mit, die danach ausdrücklich **nicht** mehr
dazugehört — die Bezugsmenge selbst bewegt sich mit jenem Übergang.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der Nachzug nicht mechanisch läuft,
  weil je Zitat erst zu klären ist, **welche** Beobachtung gemeint war — etwa dort, wo die alte
  Nummer im Fließtext ohne Link steht und der Satz mehrere Kandidaten zulässt. Dann trennt der
  Schnitt die Abbildungs-Tabelle (Nummer → Slug, aus dem Elternstand des Umzugs) von ihrem Vollzug.
- `in-progress` → `open` (blockiert — Carveout?): wenn Liefer-Punkt 2 eine Entscheidung über die
  Unveränderlichkeit von `observation.md` und `evidence/<vorgangs-id>.md` verlangt. Die gehört dem
  **Architect** ([`AGENTS.md`](../../../../AGENTS.md) §3.8 für die Regel-Ebene,
  [`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  für die Ablage) und nicht in einen Nachzug.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; das zweite und das vierte Kommando aus §1 treffen **null**; `make gates` grün;
Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Neun der 134 Vorkommen stehen in einer `Accepted`-ADR und sind nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.4 immutabel.** `docs/plan/adr/` trägt **2** Dateien mit
  **12** Vorkommen, alle dieselbe Kennung
  (`git grep -c 'BEO-[0-9][0-9][0-9]' -- 'docs/plan/adr/*.md'`); die beiden zerfallen nach Status
  und nicht nach Verzeichnis:
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) steht auf
  `Accepted` mit **9** Vorkommen und wird nicht überschrieben, sondern durch eine Folge-ADR mit
  `Supersedes` abgelöst;
  [`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) steht auf
  `Proposed` mit **3** und ist änderbar. Die Zusage von Liefer-Punkt 1 muss die eingefrorene
  Hälfte **ausnehmen** statt sie zu übersehen, sonst steht eine Vollständigkeits-Aussage neben
  einer Menge, die sie nicht erreichen darf — und die Ausnahme ist am **Status** zu treffen, nicht
  am Pfad. — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im Register>
- **Die Bezugsmenge ist ein `grep` und keine Vollständigkeitsaussage**
  ([`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md),
  5×, **geplant**). Das Muster `BEO-[0-9][0-9][0-9]` findet die dreistellige Zahl; eine
  Beobachtung, die im Fließtext nur unter ihrem Prosa-Namen genannt wird, fände es nicht — und
  **kein Modul der [`.d-check.yml`](../../../../.d-check.yml) prüft diese Klasse**, weil die Ziele
  der 46 Links auflösen und die Prosa-Zitate keine Links sind. Der Slice sagt darum die
  **getroffene** Menge zu, nicht die vollständige. — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im Register>
- **Der Nachzug ändert Artefakte, die diesem Slice nicht gehören**
  ([`BEO-ALL/anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md),
  4×, **geplant**). Drei Treffer liegen im Adaptions-Block (Architect,
  [`AGENTS.md`](../../../../AGENTS.md) §3.8), einer in einem Anweisungssatz
  ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)). Wer sie im
  selben Kontext zieht wie den Plan-Bestand, hat den Rollenwechsel übersprungen, den der
  Commit-Zuschnitt nur noch abbildet — genau der Fehler, der in
  [slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) zweimal
  auftrat. — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im Register>
- **Die sieben Vorkommen in der Ablage sind ein Auftreten von
  [`BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot`](../observations/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/observation.md)**
  (3×, `offen`) — *ein vorgeschriebener Ortswechsel macht eine Adresse in einem eingefrorenen
  Artefakt tot*, hier nicht als Adresse, sondern als Identität, und das Eingefrorene ist die
  Ablage selbst. Der Eintrag steht bereits auf der Schwelle; ob dieser Slice ihn zum vierten Mal
  belegt oder sein Ausgang wird, entscheidet der Lese-Schritt der Closure, nicht dieser
  Plan. — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im Register>

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
- **Beobachtungs-Register (`../observations/`):** <…>
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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die einzige Sub-Area,
die die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) für
Planning-Artefakte, den Adaptions-Block, die Anweisungssätze und `harness/README.md` führt.
`harness/tools/` und `.codex/` sind **nicht** berührt: keine der 23 Dateien liegt dort.

**Vorgelagert — offene Beobachtungen sichten:** Die Ablage
[`observations/`](../observations/README.md) ist vollständig durchgegangen — **41** Einträge, jeder
mit `*` (gesamtes Repo) als Sub-Area
([`BEO-ALL/sub-area-spalte-unterscheidet-nichts`](../observations/BEO-ALL/sub-area-spalte-unterscheidet-nichts/observation.md)).
Die Zähler sind abgeleitet und stehen neben dem Kommando, das sie liefert
(`for d in docs/plan/planning/observations/BEO-ALL/*/; do echo "$(ls "$d/evidence" | wc -l) $(basename "$d")"; done | sort -rn`;
Stand 2026-09-05, keine Erwartungswerte). Fünf Einträge berühren diesen Slice:

- [`verweise-brechen-beim-ortswechsel`](../observations/BEO-ALL/verweise-brechen-beim-ortswechsel/observation.md)
  (5×, **verkörpert** in `make slice-mv`) — *Verweise brechen beim Ortswechsel*. Die verkörperte
  Deckung gilt **Slice**-Adressen; eine Beobachtungs-**Kennung** hat keinen Träger, und dieser
  Slice ist der Beleg dafür, dass die Lücke real ist statt theoretisch.
- [`vorgeschriebener-ortswechsel-macht-adresse-tot`](../observations/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/observation.md)
  (3×, `offen`) — steht auf der Schwelle und trifft Liefer-Punkt 2 unmittelbar; als Risiko in §6.
- [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  (5×, **geplant** → [slice-181](slice-181-grenzen-liste-vollstaendig-oder-fail-closed.md)) —
  bindet die Formulierung von DoD 1 und 3: kein Modul sieht diese Klasse, und die DoD sagt das,
  statt `make docs-check` als Deckung anzuführen. Steht als Risiko in §6.
- [`anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md)
  (4×, **geplant**) — vier der 23 Dateien gehören anderen Rollen; steht als Risiko in §6 und prägt
  den Commit-Zuschnitt in §3.
- [`zahl-neben-nie-gefahrenem-kommando`](../observations/BEO-ALL/zahl-neben-nie-gefahrenem-kommando/observation.md)
  (3×, `offen`) — jedes Kommando in §1 ist beim Schreiben dieses Plans gefahren; die Zahlen
  daneben sind sein Ergebnis, nicht seine Erwartung.

**Keine erreicht mit diesem Slice 3×** — zwei stehen bereits darüber oder darauf und tragen ihren
Ausgang aus einer früheren Closure; keine überschreitet die Schwelle **neu**.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.

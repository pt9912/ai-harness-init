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
[slice-183](../open/slice-183-ausloeser-der-wellenlosen-archivierung.md)**, der aus demselben Katalog kommt
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
auflöst — außer an den benannten, gedeckten Ausnahmen.** Es gibt sie, und sie stehen nicht im
Kleingedruckten: vier Klassen außerhalb der Ablage, die eine Accepted-ADR, eine fremde
schreibende Rolle oder ein wörtliches Quelltext-Zitat trägt (DoD 1), und eine innerhalb, die
die Unveränderlichkeitsregel der Ablage selbst trägt (DoD 2). Jede ist gemessen, keine ist eine
übersehene Lücke. Der Satz ohne diesen Zusatz wäre eine Zusage, die die eigene DoD zwei
Abschnitte weiter zurücknimmt.

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

- [x] **Die Kennungs-Zitate außerhalb der Ablage nennen die Pfad-Form.** Jedes Vorkommen einer
      dreistelligen `BEO`-Nummer in einem lebenden Artefakt nennt stattdessen `BEO-ALL/<slug>`;
      wo das Zitat ein Markdown-Link ist, folgt sein Ziel der entschiedenen Verweis-Konvention
      (`observations/README.md` §Zwei Verweis-Formen: konkrete Beobachtung → ihre eigene
      `observation.md`). Vollständigkeit gemessen statt behauptet: das zweite Kommando aus §1
      trifft danach **16**, nicht null — und jeder der 16 zerfällt in eine von vier gemessenen,
      benannten Ausnahmen, keine davon eine übersehene Lücke:
      ```sh
      git grep -o 'BEO-[0-9][0-9][0-9]' -- '*.md' ':!.harness/baseline' ':!docs/reviews' \
        ':!docs/plan/planning/done' ':!docs/plan/planning/observations' | wc -l   # 16
      ```
      **9** in [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) —
      `Accepted`, nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 immutabel, genau die Ausnahme,
      die §6 Risiko 1 vorab benennt. **3** in
      [`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) —
      `Proposed`, damit inhaltlich änderbar, aber eine ADR-Änderung ist nach
      `modul-08-agentenrollen.md` §Rollen-Regeln *„Architect schreibt"*, unabhängig vom Status;
      das hat §6 Risiko 1 nicht vorgesehen (dort stand *„ist änderbar"* ohne die Rollen-Klausel) —
      **Übergabe an den Architect**, kein Implementer-Edit. **3** in `harness/conventions/` — Adaptions-Block,
      Architect-Artefakt nach [`AGENTS.md`](../../../../AGENTS.md) §3.8, wie in §3 geplant —
      **Übergabe an den Architect**. **Diese zwei sind die einzigen nicht dauerhaften Ausnahmen,
      und ihr Träger ist eine Datei, kein Satz:**
      [slice-189](../open/slice-189-abgeschaffte-kennung-in-architect-artefakten.md) in `open/`
      (§7). **1** in
      [slice-188](../open/slice-188-archiv-stub-kennt-die-register-verzeichnis-form.md) —
      ein **wörtliches Zitat** von `anwenden_test.go`s Testfixture-Zeichenkette, keine Zusage
      dieses Repos über die heutige Kennung; ein Nachzug würde eine falsche Aussage über den
      real vorhandenen Go-Test-Quelltext einführen (`AGENTS.md` §3.7). Das vierte Kommando aus §1
      trifft **null**:
      ```sh
      git grep -o '\[`BEO-[0-9]*`\]([^)]*observations/README\.md)' -- '*.md' \
        ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' | wc -l   # 0
      ```
      **Zeitdokumente bleiben unangetastet** — `docs/plan/planning/done/` und `docs/reviews/`
      sind Chronik von Beruf ([`AGENTS.md`](../../../../AGENTS.md) §3.7,
      [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4); sie stehen
      darum in der Bezugsmenge von §1 ausgeschlossen und nicht bloß unbearbeitet.
- [x] **Die sieben Vorkommen innerhalb der Ablage tragen einen benannten Ausgang** — geprüft statt
      angenommen: Sechs liegen in `evidence/<vorgangs-id>.md`-Dateien, alle bereits gemergt und
      damit nach `observations/README.md` §Form *unveränderlich ab Merge*. Das siebte liegt in
      der **Kurzbeschreibung** einer `observation.md` — README §Form führt drei unveränderliche
      Felder *ab Anlage* (Bezeichnung, Sub-Area, **Kurzbeschreibung**), und die zitierende Zeile
      ist genau dieses dritte Feld, nicht bloß benachbarter Fließtext. Beide Klassen sind damit
      schon heute eingefroren, nicht erst durch eine noch zu treffende Entscheidung — Liefer-Punkt
      2 aus §1 bleibt unberührt: **Ausgang aller sieben: ausdrücklich stehengelassen**, mit der
      Ablage-eigenen Unveränderlichkeitsregel als Grund. Das Auftreten der Klasse selbst — dass
      die Ablage die eigene Zitat-Form nicht nachziehen kann — ist als `evidence/slice-186.md`
      bei
      [`BEO-ALL/abgeschaffte-kennung-in-unveraenderlichem-artefakt`](../observations/BEO-ALL/abgeschaffte-kennung-in-unveraenderlichem-artefakt/observation.md)
      verbucht (§7), einer mit dieser Closure vergebenen Kennung: Die Nachbarklasse
      [`BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot`](../observations/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/observation.md)
      bindet ihre ab Anlage unveränderliche Kurzbeschreibung an die **Adresse** eines bewegten
      Artefakts in einer nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefrorenen ADR; hier
      fällt die **Identität** selbst weg, und das Eingefrorene ist die Ablage.
- [x] **Der Sichtungs-Schritt von
      [slice-181](../open/slice-181-grenzen-liste-vollstaendig-oder-fail-closed.md) §8 liest keine
      abgeschaffte Struktur mehr.** Das `awk -F'|'`-Kommando auf die Tabellenspalten des
      entfallenen Trägers ist ersetzt durch eine Schleife über die drei betroffenen Slugs, die je
      die Zahl der `evidence/`-Dateien zählt und die erste Zeile der `state.md` liest. **Eine
      Äquivalenz zum ersetzten Ausdruck wird nicht zugesagt**, und das ist der Punkt: Jener
      schnitt Kennung, Zähler und **Belegliste** aus den Tabellenspalten, dieser liefert Zähler
      und **Stand** je Slug — die Belegliste ist heute das Verzeichnis `evidence/` selbst und kein
      Feld, das man ausschneiden könnte. Zugesagt ist, was der Sichtungs-Schritt braucht: zu jeder
      der drei dort genannten Beobachtungen ihr Zähler und ihr Stand, gegen die heutige
      Verzeichnis-Form gemessen statt gegen die abgeschaffte Tabelle. **Kein Gate sieht das:** der
      Pfad steckt in einem Inline-Code-Span, der ein ganzes Shell-Kommando umfasst, und
      `make docs-check` bleibt darüber grün.
- [x] `make gates` grün.
- [x] Doku-Update: [welle-15](../welle-15-re-baseline.md) §4 führt diesen Slice bereits (Zeile
      angelegt beim Schnitt). Ein öffentlicher
      Vertrag ist **nicht** berührt — der emittierte Baum führt keine `BEO`-Kennung dieses Repos
      (`git grep -o 'BEO-[0-9][0-9][0-9]' -- internal/emit/templates | wc -l` → **0**; die
      `-c`-Form taugt hier nicht, sie schweigt bei null Treffern statt eine Null auszugeben).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag (§7).
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — drei neue Verzeichnisse und
      eine weitere Datei in einem vorhandenen `evidence/`, je ein `evidence/slice-186.md`, kein
      gesetzter Zähler (§7).
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen) — siehe §6/§7.
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit); dieses Repo führt Wellen-Betrieb, geprüft darum bei der Closure von [welle-15](../welle-15-re-baseline.md).

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
| [slice-181](../open/slice-181-grenzen-liste-vollstaendig-oder-fail-closed.md) §8 | update | Liefer-Punkt 3 — Kommando statt Zitat |

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

DoD vollständig; das vierte Kommando aus §1 trifft **null**, das zweite trifft **16** und jeder
der 16 zerfällt in eine der vier gemessenen, in DoD (1) benannten Ausnahmen (Accepted-ADR ·
Architect-Übergabe [`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) ·
Architect-Übergabe `harness/conventions/` · wörtliches Go-Test-Zitat
in slice-188), wobei die zwei Übergaben mit
[slice-189](../open/slice-189-abgeschaffte-kennung-in-architect-artefakten.md) einen Träger im
Planning-Lifecycle haben und nicht nur einen Satz in dieser Datei; `make gates` grün;
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
  am Pfad. — **Ausgang: entfallen.** DoD (1) nennt die
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)-Hälfte als
  gemessene Ausnahme, statt sie zu übersehen. Ein Zusatz-Fund, den dieser Text selbst nicht
  vorwegnahm: „änderbar" war zu grob — nach `modul-08-agentenrollen.md` §Rollen-Regeln ist *jede*
  ADR-Änderung Architect-Arbeit, unabhängig vom Status; die 3 Vorkommen von
  [`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) sind darum
  trotz `Proposed` **nicht** vom Implementer gezogen, sondern an den Architect übergeben (§7).
- **Die Bezugsmenge ist ein `grep` und keine Vollständigkeitsaussage**
  ([`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md),
  **7×**, `geplant` —
  `ls docs/plan/planning/observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/evidence | wc -l`,
  kein Erwartungswert; der Stand hat sich seit der Anlage dieses Plans bewegt, §8 nennt den
  damaligen). Das Muster `BEO-[0-9][0-9][0-9]` findet die dreistellige Zahl; eine
  Beobachtung, die im Fließtext nur unter ihrem Prosa-Namen genannt wird, fände es nicht — und
  **kein Modul der [`.d-check.yml`](../../../../.d-check.yml) prüft diese Klasse**, weil die Ziele
  der 46 Links auflösen und die Prosa-Zitate keine Links sind. Der Slice sagt darum die
  **getroffene** Menge zu, nicht die vollständige. — **Ausgang: entfallen.** Genau diese
  Zurückhaltung steht in DoD (1)/§1: die Zusage benennt ihre eigene Reichweite (16 Treffer, vier
  gemessene Ausnahmeklassen), statt Vollständigkeit zu behaupten, die der Ausdruck nicht deckt —
  das ist die Vorkehrung, die dieses Risiko verlangt hatte, nicht ihr Fehlschlag.
- **Der Nachzug ändert Artefakte, die diesem Slice nicht gehören**
  ([`BEO-ALL/anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md),
  4×, **geplant**). Drei Treffer liegen im Adaptions-Block (Architect,
  [`AGENTS.md`](../../../../AGENTS.md) §3.8), einer in einem Anweisungssatz
  ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)). Wer sie im
  selben Kontext zieht wie den Plan-Bestand, hat den Rollenwechsel übersprungen, den der
  Commit-Zuschnitt nur noch abbildet — genau der Fehler, der in
  [slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) zweimal
  auftrat. — **Ausgang: entfallen.** Der Implementer-Lauf zieht nur, was ihm gehört: die zwei
  Vorkommen in [`.claude/commands/implement-slice.md`](../../../../.claude/commands/implement-slice.md)
  sind der eigene Anweisungssatz
  ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) gibt ihn der
  ausführenden Rolle) und darum kein
  fremdes Artefakt. Die drei Vorkommen in `harness/conventions/` bleiben unangetastet — Übergabe
  an den Architect (§7), wie in §3 geplant. Derselbe Rollenwechsel gilt für die drei Vorkommen in
  [`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) (Risiko 1) —
  kein CO/Folge-Slice nötig, die Zuordnung selbst ist bereits geklärt (Modul 8, `AGENTS.md`
  §3.8).
- **Die sieben Vorkommen in der Ablage sind ein Auftreten von
  [`BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot`](../observations/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/observation.md)**
  (3×, `offen`) — *ein vorgeschriebener Ortswechsel macht eine Adresse in einem eingefrorenen
  Artefakt tot*, hier nicht als Adresse, sondern als Identität, und das Eingefrorene ist die
  Ablage selbst. Der Eintrag steht bereits auf der Schwelle; ob dieser Slice ihn zum vierten Mal
  belegt oder sein Ausgang wird, entscheidet der Lese-Schritt der Closure, nicht dieser
  Plan. — **Ausgang: weiter offen →
  [`BEO-ALL/abgeschaffte-kennung-in-unveraenderlichem-artefakt`](../observations/BEO-ALL/abgeschaffte-kennung-in-unveraenderlichem-artefakt/observation.md)
  im Register.** Die im Risiko-Text angenommene Kennung trägt den Fall **nicht**: Ihre ab Anlage
  unveränderliche Kurzbeschreibung bindet die Klasse an eine **Adresse** in einem nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefrorenen Artefakt, aufgelöst über ein
  `ignore-refs`-Paar — so liegen ihre drei vorhandenen Belege, und so liegt dieser Fall nicht.
  Hier fällt die **Identität** weg, das Eingefrorene ist die Ablage, und ein `ignore-refs`-Ventil
  gibt es dafür nicht. Der Beleg (`evidence/slice-186.md`) liegt darum bei der oben genannten,
  mit dieser Closure vergebenen Kennung; die Nachbarklasse bleibt bei drei Belegen über einem
  Gegenstand statt bei vieren über zweien. Der Lese-Schritt liegt bei diesem Repo im
  Wellen-Betrieb — er läuft bei der Closure von [welle-15](../welle-15-re-baseline.md), nicht
  hier.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (eine vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** Die mechanische Abbildung Nummer → Slug aus dem Elternstand des
  Umzugs (`9292a08^`, §1) trug über alle **15** angefassten Dateien und beide Zitat-Formen
  (Prosa-Zitat, Markdown-Link mit falschem Ziel) — kein Fall verlangte eine Neuformulierung, nur
  einen Kennungs-Austausch. Die Zahl ist die der Dateien, in denen eine dreistellige Nummer
  verschwand, und nicht die Trefferzahl aus DoD 1 (kein Erwartungswert):

  ```sh
  git show e8cde04 --unified=0 \
    | awk '/^diff --git/{f=$3; sub(/^a\//,"",f)} /^-/ && !/^---/ && /BEO-[0-9][0-9][0-9]/{print f}' \
    | sort -u | wc -l                                                                    # 15
  ```
- **Was ging anders als geplant:** §6 Risiko 1 nannte
  [`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) als *„Proposed
  … und ist änderbar"* und legte damit nahe, der Implementer könne ihre drei Vorkommen im selben
  Zug ziehen wie die Plan-Dateien. Das trägt nicht: `modul-08-agentenrollen.md` §Rollen-Regeln
  gibt *jede* ADR-Änderung dem Architect, unabhängig vom Status — der `Proposed`-Status macht die
  ADR inhaltlich änderbar, nicht die Rolle, die sie ändert. Sie bleibt darum unangetastet,
  wie die neun Vorkommen der `Accepted`-Hälfte. Zusätzlich stellte sich die Trennung zwischen
  „gehört einer anderen Rolle" und „ist einfach mein eigener Anweisungssatz" als schärfer heraus
  als der Plan sie zeichnete: `.claude/commands/implement-slice.md` steht zwar in derselben
  Pfad-Klasse wie `harness/conventions/`, gehört aber der **ausführenden** Rolle
  ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)) und damit hier
  dem Implementer selbst. Und die Umbuchung des Register-Belegs (§6 Risiko 4) hat zwei Adressen
  im Review-Report dieses Slice tot gemacht — `make docs-check` meldete sie als
  `target-missing`. Repariert ist die **Adresse**, nicht der Text: die zwei Markdown-Links stehen
  jetzt als Inline-Code-Pfad, den `.d-check.yml` für `docs/reviews/**` ausdrücklich ausnimmt
  (*„Zeitdokumente … frieren den Stand ihres Review-Laufs ein; Lifecycle-Pfade darin veralten per
  Definition"*). Dieselbe Operation fährt `make slice-mv` bei jedem Lifecycle-Wechsel selbst über
  `docs/reviews/**`; hier kannte sie den Pfad nicht, weil er keine Slice-Datei ist. Der Befund und
  seine Fundstelle bleiben wörtlich stehen.
- **Steering-Loop-Eintrag:** *benannte Spec-Lücke.* Keine Quelle sagt, wie ein Artefakt nachzieht,
  dessen zitierte **Identität** abgeschafft wurde, während eine Ablage-Regel es unveränderlich
  hält — `observation.md` ab Anlage, `evidence/<vorgangs-id>.md` ab Merge
  ([`observations/README.md`](../observations/README.md) §Form, und Modul 6 ebenso). Die Regel
  trägt die Unveränderlichkeit unbedingt und kennt den Fall nicht, dass das Zitierte selbst
  wegfällt; die Folge ist ein Register, das die eigene Kennungs-Form nicht nachziehen kann. Kein
  Sensor prüft das
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6));
  der Eintrag ist **gezählt, nicht verkörpert**, und seine Route in den Zähler ist
  [`BEO-ALL/abgeschaffte-kennung-in-unveraenderlichem-artefakt`](../observations/BEO-ALL/abgeschaffte-kennung-in-unveraenderlichem-artefakt/observation.md).
  Die Fehl-Annahme über den `Proposed`-Status steht dafür **nicht** hier: Sie ist keine Lücke,
  denn `modul-08-agentenrollen.md` §Rollen-Regeln entscheidet sie ohne Vorbehalt — sie steht als
  Korrektur unter *Was ging anders als geplant*.
- **Beobachtungs-Register (`../observations/`):** vier Einträge, je ein `evidence/slice-186.md`,
  kein Zähler gesetzt. Drei Verzeichnisse **neu angelegt** —
  [`abgeschaffte-kennung-in-unveraenderlichem-artefakt`](../observations/BEO-ALL/abgeschaffte-kennung-in-unveraenderlichem-artefakt/observation.md)
  (die sieben Zitate in der Ablage, §6 Risiko 4),
  [`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md)
  (die zwei falschen Zahlen dieses Zuges, oben und in §6) und
  [`uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md)
  (die Übergabe ohne Slice-Datei). Jede der drei ist vergeben, **weil** die nächstliegende
  vorhandene Kennung sie in ihrer unveränderlichen Kurzbeschreibung ausschließt — die Abgrenzung
  steht in der jeweiligen `observation.md`, damit die Klasse sich nicht still in zwei Pfade
  teilt. Ergänzt wurde
  [`fremdes-rollen-artefakt-im-implementations-kontext`](../observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md);
  der Eintrag stand vor diesem Slice schon auf der Schwelle, sein Ausgang steht dem Lese-Schritt
  der Closure von [welle-15](../welle-15-re-baseline.md) zu und wird hier **nicht** zugewiesen.
  Zähler-Stände: `for s in abgeschaffte-kennung-in-unveraenderlichem-artefakt zahl-ohne-kommando-trifft-ihren-gegenstand-nicht uebergabe-an-andere-rolle-ohne-traeger-artefakt fremdes-rollen-artefakt-im-implementations-kontext; do d="docs/plan/planning/observations/BEO-ALL/$s"; echo "$s $(ls "$d/evidence" | wc -l)x"; done`
  (keine Erwartungswerte).
- **Folge-Slices:** [slice-189](../open/slice-189-abgeschaffte-kennung-in-architect-artefakten.md)
  — *Die abgeschaffte Beobachtungs-Kennung zieht in den Architect-Artefakten nach*, eine Datei in
  `open/`. Sie trägt die zwei Übergaben, die dieser Slice nicht selbst ziehen darf: die Vorkommen
  in [`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md)
  (`BEO-<NNN>` → `BEO-ALL/anweisungssatz-eigentum-ohne-quelle`) und die in
  [`MR-041`](../../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline),
  [`MR-047`](../../../../harness/conventions.md#mr-047--der-ort-der-ausführbaren-harness-tools-ist-keine-abweichung-mehr),
  [`MR-048`](../../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag)
  (`BEO-<NNN>` → `BEO-ALL/adaptions-achse-1-kurzschluss` — dort steht das Linkziel bereits
  richtig, nur das Label ist stehengeblieben). **Eine Übergabe ohne Slice-Datei wäre keine:**
  Modul 8 §Die neun Übergaben nennt für Planner → Architect den Slice-Plan als Artefakt, und der
  einzige andere Träger wäre diese Closure-Notiz gewesen, die mit dem `git mv` Chronik wird
  ([`AGENTS.md`](../../../../AGENTS.md) §3.7). Die Vorkommen in
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) gehen dort
  ausdrücklich **nicht** mit: `Accepted` und nach §3.4 nur über eine Folge-ADR mit `Supersedes`
  änderbar — ein anderer Gegenstand, kein Nachzug.
- **Risiken aus §6:** vier notiert, vier mit genau einem Ausgang — dreimal *entfallen* mit
  Begründung, einmal *weiter offen* mit Register-Verweis. Keines steht ohne Ausgang da.
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
  (5×, **geplant** → [slice-181](../open/slice-181-grenzen-liste-vollstaendig-oder-fail-closed.md)) —
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

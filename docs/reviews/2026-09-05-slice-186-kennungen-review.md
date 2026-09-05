# Review — slice-186: Jede zitierte Beobachtungs-Kennung löst wieder auf

## Kopf-Metadaten

- **Rolle:** Reviewer (Modul 8/10), frischer Kontext, kein Selbst-Review.
  Skill: [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) `1.7.0`.
- **Datum:** 2026-09-05
- **Gegenstand:** [slice-186](../plan/planning/done/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md)
  — noch **nicht** geschlossen (`in-progress/`).
- **Commit:** `e8cde04` (ein Commit, 17 Dateien —
  `git show --stat e8cde04`). Die vier `slice-mv`-Commits davor
  (`f1daab0`, `4a468ed`, `1e68326`, `f3c6a26`) und `055e47b` sind Lifecycle-Bewegung und nicht
  Gegenstand dieses Reviews.
- **Berührte `LH-*`:** [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
  (die abgeschaffte Kennungs-Form kommt aus dem auf einen Tag gepinnten Baum) ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  (kein Modul sieht diese Klasse — die DoD darf keinen Sensor als Deckung anführen).
- **Referenzierte ADRs (Status selbst gemessen, `grep -m1 '^\*\*Status:\*\*'`):**
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) `Accepted` ·
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) `Accepted` ·
  [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) `Accepted` ·
  [ADR-0029](../plan/adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) **`Proposed`**.
  Keine superseded ADR referenziert.
- **Hard Rules geprüft:** [`AGENTS.md`](../../AGENTS.md) §3.1, §3.3, §3.4, §3.5, §3.6, §3.7, §3.8, §3.9.
- **Vorherige Findings am gleichen Modul:**
  [`2026-09-05-slice-177-register-verzeichnis-form-review.md`](2026-09-05-slice-177-register-verzeichnis-form-review.md)
  (MEDIUM-1 *zirkuläre Zuweisung der Adress-Hälfte*, HIGH-4 *Implementer schreibt in fremdes
  Rollen-Artefakt*) ·
  [`2026-09-05-slice-177-register-verzeichnis-form-review-runde-2.md`](2026-09-05-slice-177-register-verzeichnis-form-review-runde-2.md)
  (MEDIUM-3 *`awk` auf die abgeschaffte Tabelle*, MEDIUM-5 *46 Links widersprechen der
  Verweis-Konvention* — beide sind der Liefergegenstand dieses Slice) ·
  [`2026-09-05-slice-178-nachtraeglich-review.md`](2026-09-05-slice-178-nachtraeglich-review.md)
  (MEDIUM-4 *Rollenwechsel ohne Übergabe-Artefakt*) ·
  [`2026-09-05-slice-185-adaptions-durchgang-review.md`](2026-09-05-slice-185-adaptions-durchgang-review.md)
  (MEDIUM-3 dieselbe Klasse, zweite Instanz). Sie tritt hier zum **dritten** Mal auf (MEDIUM-1).
- **Selbst gefahrene Sensoren:** `make gates` → **EXIT 0** ·
  `d-check: 807 Datei(en) geprüft, 0 Befund(e)` · `comment-claims: 55 Datei(en) geprueft,
  0 Befund(e)` · `span-check` grün.

**Was dieser Report nicht ist:** kein Verifier. Die DoD-Abhakung und das Plan-vs-Code-Urteil
prüft die Verifikation in getrenntem Kontext.

---

## Vorbemerkung — was ich unabhängig nachgemessen habe

Die Kernbehauptung des Slice ist eine **Vollständigkeits-Aussage mit vier benannten Ausnahmen**.
Sie ist nicht übernommen, sondern nachgefahren.

**Die 16 sind reproduziert und nach Datei aufgeschlüsselt:**

```sh
git grep -o 'BEO-[0-9][0-9][0-9]' -- '*.md' ':!.harness/baseline' ':!docs/reviews' \
  ':!docs/plan/planning/done' ':!docs/plan/planning/observations' | wc -l    # 16
git grep -o 'BEO-[0-9][0-9][0-9]' -- '*.md' ':!.harness/baseline' ':!docs/reviews' \
  ':!docs/plan/planning/done' ':!docs/plan/planning/observations' \
  | cut -d: -f1 | sort | uniq -c | sort -rn
#  9 docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md
#  3 docs/plan/adr/0029-agenten-typkarten-derivativ-gemischte-originale.md
#  1 harness/conventions/MR-041-…​.md
#  1 harness/conventions/MR-047-…​.md
#  1 harness/conventions/MR-048-…​.md
#  1 docs/plan/planning/open/slice-188-archiv-stub-kennt-die-register-verzeichnis-form.md
```

Die Aufteilung deckt sich mit der DoD Zeile für Zeile. **Jede der vier Ausnahmen trägt** — siehe
Negativbefunde N-1 bis N-4; die `ADR-0029`-Begründung habe ich gegen den Wortlaut von
`modul-08-agentenrollen.md` §Rollen-Regeln geprüft und sie hält.

**Der Nachzug selbst ist mechanisch nachgeprüft, nicht stichprobenartig.** Für jede der 17 Dateien
des Commits habe ich die Token-Folge `BEO-<NNN>|BEO-ALL/<slug>` aus dem Elternstand geholt, die
Nummern über den Verzeichnisbaum `9292a08^` auf ihre Slugs abgebildet und gegen die Token-Folge des
neuen Standes gehalten. Abbildungs-Tabelle:

```sh
git ls-tree -d -r --name-only 9292a08^ docs/plan/planning/observations/ \
  | sed 's|docs/plan/planning/observations/||' | grep -E '^BEO-[0-9]{3}/[a-z0-9-]+$' | wc -l   # 41
```

Kein Fall bildet auf einen falschen Slug ab. Die Differenzen zwischen alter und neuer Folge sind
ausnahmslos **Zuwächse** an der Stelle, an der ein Link jetzt den Slug zweimal trägt (Label und
Ziel) — genau die von `observations/README.md` §Zwei Verweis-Formen verlangte Gestalt.

**Label und Ziel decken sich in allen 67 Links:**

```sh
git grep -o '\[`BEO-ALL/[a-z0-9-]*`\]([^)]*observation\.md)' -- '*.md' ':!.harness/baseline' | wc -l   # 67
```

Der Abgleich Label gegen Ziel-Slug (`awk`-Vergleich über dieselbe Trefferliste) liefert **keine**
Abweichung.

**Der Commit fasst nichts an, was nicht zum Gegenstand gehört.** Jede geänderte Zeile außerhalb der
Plan-Datei und der neuen Beleg-Datei trägt ein `BEO`-Token; die drei Ausnahmen sind
Zeilenumbruch-Nachbarn desselben Satzes
(`git show e8cde04 -- . ':!…slice-186….md' ':!docs/plan/planning/observations' | grep -E '^[-+]' | grep -v 'BEO-'`
→ 3 Zeilen, alle Umbruch).

**Die Zahlen des Plans §1 sind am Anlage-Stand nachgemessen** (`d5a35ca`, der Commit, der die
Plan-Datei anlegt): 23 Dateien · 134 Vorkommen · 7 innerhalb der Ablage · 46 Links · 15 in
Zielform. Alle fünf treffen. Ebenso §8: 41 Einträge und die fünf zitierten Zähler-Stände
(5/3/5/4/3) sind am Anlage-Stand korrekt — der wiederkehrende Fund *Sichtungs-Schritt zitiert
falschen Zähler-Stand* tritt hier **nicht** ein.

---

## Findings

### MEDIUM-1 — Die Closure-Schritte und die Plan-Änderung laufen im Implementations-Commit, vor Review und Verifikation

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk
  [`modul-08-agentenrollen.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-08-agentenrollen.md)
  §Rollen-Sequenz für einen Slice (`I→R→Vf→P`, *„Closure in `done/` + Lerneintrag"* beim Planner)
  und §Rollen-Regeln (*„kein Rollenwechsel ohne Übergabe-Artefakt"*) ·
  [`.claude/commands/implement-slice.md`](../../.claude/commands/implement-slice.md)
  §Closure — **Planner-Rolle**, Schritt 23 (*„Erst wenn der Review konform **und** die Verifikation
  die DoD bestätigt hat, schließt der **Planner**"*) und Schritt 24 (*„der **Schreib**-Schritt, und
  er hängt an der Closure, nicht an der Implementation"*)
- **pfad:** `e8cde04` —
  [`…/slice-186-…md`](../plan/planning/done/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md)
  §2 (zehn DoD-Häkchen **und** der umgeschriebene DoD-Text), §5, §6 (vier Risiko-Ausgänge),
  §7 (vollständige Closure-Notiz) sowie
  `docs/plan/planning/observations/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/evidence/slice-186.md`
- **befund:** Derselbe Lauf, der den Nachzug schrieb, hat im selben Commit die Closure-Notiz §7,
  die vier Risiko-Ausgänge §6, den Closure-Trigger §5, die DoD-Häkchen **und** den Register-Beleg
  geschrieben — sämtlich Schritte, die der repo-eigene Anweisungssatz unter die Überschrift
  *Closure — Planner-Rolle* stellt und ausdrücklich hinter Review und Verifikation legt. Zwischen
  dem schreibenden und dem schließenden Kontext liegt kein Übergabe-Artefakt. Verschärfend: derselbe
  Commit **ändert** die Datei, deren Schritt-Reihenfolge er unterläuft
  (`.claude/commands/implement-slice.md`, zwei Zeilen). Der Kopf des Plans trägt
  `Verantwortlich: Implementer (pt9912)`; das Feld benennt nach
  [`modul-05-planning-harness.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-05-planning-harness.md)
  §Lifecycle als State Machine den Rolleninhaber der **Implementer**-Rolle, nicht den der Closure.
  Über die reine Closure hinaus geht die **Änderung der Abnahme-Zusage selbst**: DoD 1 lautete
  *„das zweite Kommando aus §1 trifft danach **null**, das vierte ebenfalls"* und lautet jetzt
  *„trifft danach **16**"* — die ausführende Rolle hat ihr eigenes Abnahmekriterium umgeschrieben,
  statt es an den Planner zurückzugeben.
- **verifizierbar:** **nein** — kein Modul der [`.d-check.yml`](../../.d-check.yml) liest Commits
  (`grep -n 'modules:' .d-check.yml` → `[links, anchors, ids, matrix, codepaths, spans]`), und
  `make mutate` kennt keine Fehlschlag-Form für einen Commit-Zuschnitt. Ablesbar an
  `git show --stat e8cde04` und `git show e8cde04 -- docs/plan/planning/in-progress/slice-186-*.md`.
- **klasse:** *Rollenwechsel ohne Übergabe-Artefakt* — **dritte** Instanz nach
  [`2026-09-05-slice-178-nachtraeglich-review.md`](2026-09-05-slice-178-nachtraeglich-review.md)
  MEDIUM-4 und
  [`2026-09-05-slice-185-adaptions-durchgang-review.md`](2026-09-05-slice-185-adaptions-durchgang-review.md)
  MEDIUM-3. Die Register-Klasse
  [`fremdes-rollen-artefakt-im-implementations-kontext`](../plan/planning/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md)
  steht bei **3×**
  (`ls docs/plan/planning/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/evidence | wc -l`),
  ihr `state.md` sagt *„Die Schwelle ist mit dem Beleg zu `slice-185` erreicht"*. Nach Modul 8
  §Konflikt-Pfad (*„ab dem **dritten** gleichen Konflikttyp"*) ist das keine Notiz mehr.
- **Abgrenzung, damit die Quelle stimmt:** [`AGENTS.md`](../../AGENTS.md) §3.8 ist **nicht**
  verletzt — sie bindet Hard Rules und den Adaptions-Block, und beide sind unangetastet (N-6).
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) ist **nicht**
  verletzt: `implement-slice.md` gehört dem Implementer (N-7). Träger dieses Befundes sind Modul 8
  und der repo-eigene Anweisungssatz.
- **Mildernd, und es gehört genannt:** Der Plan war an dieser Stelle **in sich widersprüchlich**.
  DoD 1 sagte *„trifft danach null"*, §6 Risiko 1 desselben Plans sagte *„Die Zusage von
  Liefer-Punkt 1 muss die eingefrorene Hälfte **ausnehmen** statt sie zu übersehen"*. Beides
  zugleich ist nicht erfüllbar; die Nachbesserung war **sachlich fällig**. Der Defekt ist die
  fehlende Übergabe, nicht die Richtung der Änderung.

### MEDIUM-2 — §7 sagt vom Steering-Loop-Eintrag „der Eintrag ist gezählt"; kein Register-Verzeichnis führt diese Klasse

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk
  [`modul-06-roadmap.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-06-roadmap.md)
  §Das Beobachtungs-Register (*„Eingetragen wird bei der **Slice-Closure** — neues Verzeichnis …,
  oder eine weitere Datei in das vorhandene `evidence/`"*) ·
  [`.claude/commands/implement-slice.md`](../../.claude/commands/implement-slice.md) Schritt 24
  (*„Für jede Beobachtung aus §7"*) · [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** [`…/slice-186-…md`](../plan/planning/done/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md)
  §7, Punkt *Steering-Loop-Eintrag*
- **befund:** Der Lerneintrag benennt eine neue Klasse — *„§6 Risiko 1 und §3 der Plan-Tabelle
  behandelten „Proposed-ADR" als gleichbedeutend mit „vom Implementer änderbar""* — und schließt
  mit *„der Eintrag ist gezählt, nicht verkörpert"*. Gezählt ist er nicht: Der Commit legt genau
  **eine** Beleg-Datei an, und sie gehört zu `vorgeschriebener-ortswechsel-macht-adresse-tot`.
  Unter den 46 Einträgen des Registers führt keiner diese Klasse
  (`head -1 -q docs/plan/planning/observations/BEO-ALL/*/observation.md`; die Nachbarn
  [`proposed-adr-annahme-ohne-repo-internen-traeger`](../plan/planning/observations/BEO-ALL/proposed-adr-annahme-ohne-repo-internen-traeger/observation.md)
  und
  [`anweisungssatz-eigentum-ohne-quelle`](../plan/planning/observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md)
  tragen andere Gegenstände). Weil §7 zu diesem Eintrag **keine** Kennung nennt, greift auch die
  Register-Paarung (c) nicht: Sie prüft genannte Kennungen auf Existenz, nicht ungenannte auf
  Anlage. Das konkrete Versagen: Der Zähler dieser Klasse bleibt bei null, sie erreicht nie 3×, und
  der Text, der sie benennt, wandert mit der Slice-Closure nach `done/` und von dort ins Archiv.
- **verifizierbar:** **nein** — die drei Paarungen der Welle-Closure prüfen die **genannte**
  Richtung; kein Modul der [`.d-check.yml`](../../.d-check.yml) liest Closure-Notizen auf
  ungenannte Beobachtungen. Ablesbar an
  `git show --stat e8cde04 | grep evidence` (**eine** Datei) gegen §7.
- **klasse:** *Lerneintrag ohne Route in den Zähler*

### MEDIUM-3 — Der vierte Beleg bucht eine andere Klasse unter eine Kennung, deren unveränderliche Kurzbeschreibung sie nicht deckt

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk
  [`modul-06-roadmap.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-06-roadmap.md)
  §Das Beobachtungs-Register (*„Der Pfad ersetzt die Namens-Disziplin … Mensch urteilt, Maschine
  prüft Deckung"*; `observation.md` *unveränderlich ab Anlage*) ·
  [`observations/README.md`](../plan/planning/observations/README.md) §Form
- **pfad:** `docs/plan/planning/observations/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/evidence/slice-186.md`
- **befund:** Die Kurzbeschreibung des Eintrags bindet die Klasse an zwei Merkmale: *„eine
  **Adresse** in einem nach `AGENTS.md` **§3.4** eingefrorenen Artefakt"*. Der neue Beleg trifft
  keines von beiden und sagt das selbst: *„Die Klasse trifft hier nicht die **Adresse** eines
  bewegten Artefakts, sondern die **Identität** einer zitierten Beobachtung selbst"*; das
  eingefrorene Artefakt ist die Ablage, deren Unveränderlichkeit aus
  [`observations/README.md`](../plan/planning/observations/README.md) §Form stammt und nicht aus
  §3.4. Die drei vorhandenen Belege (`slice-154`, `slice-156`, `slice-179`) sind sämtlich tote
  **Link-Adressen** in `Accepted`-ADRs, aufgelöst über `ignore-refs`-Paare. Der Zähler steht damit
  bei **4×** über zwei verschiedenen Gegenständen. Das konkrete Versagen liegt vor dem Repo:
  Der Ausgang dieses Eintrags ist beim Lese-Schritt der
  [welle-15](../plan/planning/welle-15-re-baseline.md)-Closure fällig; er wird an drei
  ADR-Adress-Fällen bemessen und deckt den Identitäts-Fall nicht — und die Kurzbeschreibung ist
  *ab Anlage unveränderlich* und kann nicht nachgezogen werden.
- **verifizierbar:** **nein** — maschinell prüfbar ist nach Modul 6 nur die Deckung (Verzeichnis
  existiert, `evidence/` nicht leer), nicht die Klassen-Zugehörigkeit. Ablesbar am Vergleich von
  `observation.md` mit den vier Dateien in `evidence/`.
- **klasse:** *Beleg bucht unter fremde Kennung*

### MEDIUM-4 — §7 nennt „16 lebende Dateien" ohne Kommando; gemessen sind es 15

- **kategorie:** MEDIUM
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 (*„trägt im selben Absatz das Kommando, das **genau sie** ausgibt"*) — vom Plan §1
  ausdrücklich in Bezug genommen (*„jede Zahl unten steht neben ihrem Kommando"*)
- **pfad:** [`…/slice-186-…md`](../plan/planning/done/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md)
  §7, Punkt *Was hat funktioniert*
- **befund:** Der Satz *„trug über alle **16** lebenden Dateien und beide Zitat-Formen"* trägt kein
  Kommando, und die Zahl trifft nicht. Der Commit ersetzt eine `BEO-<NNN>` in **15** Dateien:

  ```sh
  git show e8cde04 --unified=0 \
    | awk '/^diff --git/{f=$3; sub(/^a\//,"",f)} /^-/ && !/^---/ && /BEO-[0-9][0-9][0-9]/{print f}' \
    | sort -u | wc -l                                                                     # 15
  ```

  Gegenprobe über die Bezugsmenge: `git grep -l 'BEO-[0-9]' e8cde04^ -- '*.md' ':!.harness/baseline'
  ':!docs/reviews' ':!docs/plan/planning/done' ':!docs/plan/planning/observations' | wc -l` → **21**,
  davon bleiben **6** als benannte Ausnahmen stehen; 21 − 6 = 15. Die **16** ist die Trefferzahl aus
  DoD 1, nicht eine Dateizahl.
- **verifizierbar:** **nein** — kein Modul prüft Prosa-Zahlen gegen ihren Gegenstand
  ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
  Ablesbar am Kommando oben.
- **klasse:** *Zahl neben nie gefahrenem Kommando* — vorhandene Kennung
  [`zahl-neben-nie-gefahrenem-kommando`](../plan/planning/observations/BEO-ALL/zahl-neben-nie-gefahrenem-kommando/observation.md)
  (**3×**), hier zusätzlich mit falschem Wert.

### MEDIUM-5 — Die zwei „Übergaben an den Architect" haben keinen Träger außerhalb dieses Plans

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk
  [`modul-08-agentenrollen.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-08-agentenrollen.md)
  §Die neun Übergaben (*„Ohne **jedes** dieser Artefakte gibt es keinen Rollenwechsel — nur einen
  Kontext-Switch ohne Übergabe"*) und §Konflikt-Pfad (*„Kein Pfeil ohne benennbares Artefakt"*) ·
  [`modul-05-planning-harness.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-05-planning-harness.md)
  §Offene Risiken werden bei Closure aufgelöst
- **pfad:** [`…/slice-186-…md`](../plan/planning/done/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md)
  §7, Punkt *Folge-Slices*; DoD 1
- **befund:** Sechs der 16 verbliebenen Vorkommen — 3 in
  [ADR-0029](../plan/adr/0029-agenten-typkarten-derivativ-gemischte-originale.md), 3 in
  `harness/conventions/` — sind **nicht** dauerhaft ausgenommen, sondern als *„Übergabe an den
  Architect"* deklariert; §7 sagt zugleich *„Folge-Slices: keine"*. Ein Artefakt, das diese
  Übergabe trägt, existiert nicht: Kein Plan in `open/`, `next/` oder `in-progress/` und kein
  Welle-Plan nennt den Nachzug in `harness/conventions/` oder `ADR-0029`
  (`git grep -ln 'Kennungs-Nachzug\|BEO-ALL/adaptions-achse-1-kurzschluss' -- docs/plan/planning/open
  docs/plan/planning/next docs/plan/planning/in-progress docs/plan/planning/welle-15-re-baseline.md`
  → zwei Treffer, beide bloße Zitate der Beobachtung, keine Zusage über den Nachzug). Der einzige
  Träger ist §7 dieser Plan-Datei, die mit der Closure nach `done/` wandert und dort Chronik ist
  ([`AGENTS.md`](../../AGENTS.md) §3.7) und nach
  [`modul-06-roadmap.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-06-roadmap.md) Schritt 4
  auf einen Stub gekürzt wird. Das konkrete Versagen: `git grep 'BEO-[0-9][0-9][0-9]'` liefert
  dauerhaft sechs lebende Treffer, für die niemand mehr zuständig ist — die Klasse, gegen die der
  Slice angetreten ist, überlebt ihn in halber Größe.
- **verifizierbar:** **nein** — die Folge-Slice-Paarung prüft **genannte** Folge-Slices auf
  Existenz; ein ausdrückliches *„Folge-Slices: keine"* ist für sie kein Gegenstand.
- **klasse:** *Ausgang nennt Träger, der nicht trägt* — Nachbarklasse zur vorhandenen Kennung
  [`ausgang-nennt-traeger-der-nicht-traegt`](../plan/planning/observations/BEO-ALL/ausgang-nennt-traeger-der-nicht-traegt/observation.md)
  (**2×**); dort nennt der Ausgang eine Kennung, deren DoD nicht trägt, hier nennt er **gar keine**.
  Ob das dieselbe Kennung ist, entscheidet der schreibende Lauf.

### LOW-1 — Der Ziel-Satz in §1 steht unqualifiziert neben einer DoD mit 16 Ausnahmen

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„Eine Zusage … ist erst fertig, wenn benannt
  ist, was passieren müsste, damit sie bricht"*)
- **pfad:** [`…/slice-186-…md`](../plan/planning/done/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md)
  §1, erster fett gesetzter Satz
- **befund:** §1 führt als Ziel *„**Kein lebendes Artefakt dieses Repos zitiert eine Beobachtung
  unter einer Kennung, die nicht mehr auflöst.**"* Nach dem Slice zitieren **23** Stellen eine
  solche Kennung — 16 außerhalb und 7 innerhalb der Ablage (beide Zahlen oben gemessen). Der Satz
  ist der einzige Ort, an dem der Gegenstand ohne Einschränkung formuliert ist; DoD 1 und DoD 2
  darunter benennen ihre Reichweite korrekt. Ein Leser, der §1 zitiert — etwa die
  welle-15-Closure —, übernimmt eine Zusage, die der eigene Plan zwei Abschnitte weiter widerlegt.
- **verifizierbar:** **nein** — kein Modul prüft Ziel-Sätze gegen ihre DoD.
- **klasse:** *Zusage greift weiter als Abdeckung*

### LOW-2 — DoD 3 behauptet „dieselbe Aussage"; das ersetzte Kommando gab andere Felder aus, und die Gate-Offenlegung ist weggefallen

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** [`…/slice-186-…md`](../plan/planning/done/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md)
  DoD 3 · [`…/slice-181-…md`](../plan/planning/open/slice-181-grenzen-liste-vollstaendig-oder-fail-closed.md) §8
- **befund:** Die neue Mess-Methode **funktioniert** — selbst gefahren, Ausgabe:
  `zusage-neben-geaenderter-ableitung-bleibt-stehen 13x **Stand:** geplant` ·
  `schwellen-uebertritt-ohne-zustaendige-rolle 2x **Stand:** offen` ·
  `zusage-nennt-sensor-der-form-nicht-sieht 7x **Stand:** geplant`. Sie misst aber **nicht**
  dasselbe wie die ersetzte. Das alte `awk -F'|' '/BEO-0(09|22|25)/ {print $2, $5, $6}'` gab
  **Kennung, Zähler und Belegliste** aus, nicht den Stand — nachgefahren gegen die letzte Fassung
  der abgeschafften Datei:
  `git show ed0a661^:docs/plan/planning/observations.md | awk -F'|' '/BEO-0(09|22|25)/ {print $2, $5, $6}'`
  → acht Zeilen, darunter `BEO-009  11×  slice-144, …`. DoD 3 sagt *„dieselbe Aussage (Stand +
  Zähler je Beobachtung)"*; ausgetauscht ist die Belegliste gegen den Stand, und die Trefferzahl
  fällt von acht auf drei. Zusätzlich ist mit der Umformulierung die Offenlegung aus dem alten
  DoD-3-Text verschwunden (*„**Kein Gate sieht das:** … `make docs-check` bleibt darüber grün"*);
  DoD 3 führt jetzt keine Aussage mehr darüber, dass die neue Methode ungewächtert ist.
- **verifizierbar:** **teilweise** — dass das neue Kommando läuft, ist oben gefahren; dass die
  Feld-Auswahl differiert, zeigt der `git show`-Vergleich. Kein Gate deckt beides.
- **klasse:** *Ersatz-Messung ohne Äquivalenz-Beleg*

### LOW-3 — Ein vom Commit angefasster §6-Absatz führt „5×", gemessen sind es 7×

- **kategorie:** LOW
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2 · [`AGENTS.md`](../../AGENTS.md) §3.7, Zustandsfeld-Hälfte (*„Gebunden ist die Zelle,
  die geschrieben oder geändert wird"*)
- **pfad:** [`…/slice-186-…md`](../plan/planning/done/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md)
  §6, zweites Risiko
- **befund:** Der Absatz führt
  [`zusage-nennt-sensor-der-form-nicht-sieht`](../plan/planning/observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  mit *„5×, **geplant**"*. Der Zähler steht bei **7**
  (`ls docs/plan/planning/observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/evidence | wc -l`);
  bei Anlage des Plans waren es 5, der Stand hat sich mit der `slice-185`-Closure bewegt. Dieser
  Commit hat genau diesen Absatz angefasst (Ausgang angehängt) und die Zahl stehen lassen. Sie trägt
  kein Kommando und ist nicht als *kein Erwartungswert* gekennzeichnet. §8 desselben Plans ist
  davon **nicht** betroffen: dort ist die 5× am Anlage-Stand korrekt und der Absatz unangetastet.
- **verifizierbar:** **nein** — der Zähler ist abgeleitet, kein Sensor hält Prosa dagegen.
- **klasse:** *Zahl neben nie gefahrenem Kommando*

### INFO-1 — Der Lerneintrag ist als „benannte Spec-Lücke" klassifiziert, obwohl die Norm existiert und eindeutig ist

- **kategorie:** INFO
- **quelle:** Baseline-Regelwerk
  [`modul-05-planning-harness.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-05-planning-harness.md)
  §Closure- und Lerneintrag-Regeln (drei Formen: *geschärfte Regel · neuer Sensor · benannte
  Spec-Lücke*)
- **pfad:** [`…/slice-186-…md`](../plan/planning/done/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md)
  §7, Punkt *Steering-Loop-Eintrag*
- **befund:** Der Eintrag firmiert als *benannte Spec-Lücke*, beschreibt aber keine Lücke in einer
  Spec: `modul-08-agentenrollen.md` §Rollen-Regeln sagt *„ADR-Änderung: Architect schreibt"* ohne
  Status-Vorbehalt, und
  [`AGENTS.md`](../../AGENTS.md) §3.8 zitiert denselben Satz. Was fehlt, ist ein **Wächter** — was
  der Eintrag im nächsten Satz selbst sagt (*„Kein Sensor prüft das"*). Die dritte Form wäre
  *neuer Sensor*, und sie ist nicht geliefert; die Klassifikation verschiebt eine offene
  Trägerfrage in eine Kategorie, die sie als Spec-Problem ausweist.
- **verifizierbar:** **nein**
- **klasse:** *Lerneintrag-Form trifft den Gegenstand nicht*

---

## Negativbefunde (geprüft, ohne Befund)

- **N-1 — Ausnahme 1 (`ADR-0028`, 9 Vorkommen) trägt, und sie ist materiell folgenlos.** Status
  selbst gemessen: `Accepted`, damit nach [`AGENTS.md`](../../AGENTS.md) §3.4 immutabel. Darüber
  hinaus laufen die Vorkommen dort weiter: Die ADR pinnt ihre Messung auf eine Mess-Basis, und das
  Kommando ist von mir gefahren —
  `git show 7485be3:docs/plan/planning/observations.md | awk -F'|' '$2 ~ /BEO-007/{print $5, $6}'`
  → `4×   slice-137, slice-144, slice-147, slice-148`, exakt der abgedruckte Wert. Die Kennung löst
  am gepinnten Ref auf; es steht keine tote Adresse in der ADR.
- **N-2 — Ausnahme 2 (`ADR-0029`, 3 Vorkommen) trägt, und die Begründung ist die richtige.**
  Status selbst gemessen: `Proposed`. Der Statuswert macht die ADR **inhaltlich** änderbar; wer sie
  ändert, sagt er nicht.
  [`modul-08-agentenrollen.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-08-agentenrollen.md)
  §Rollen-Regeln trennt beides in einem Satz: *„ADR-Änderung: Architect schreibt … Accepted-ADRs
  überschreibt **niemand**"* — die erste Hälfte ist status-unabhängig, die zweite ist der Zusatz
  für `Accepted`. Der Implementer liest *„als Constraint"*. Die Ausnahme *„Architect-Sache trotz
  `Proposed`"* ist damit korrekt und die Plan-Prämisse *„ist änderbar"* zu grob — genau wie §7 es
  selbst sagt. Gegenprobe an
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md): deren Festlegung 1
  ordnet Anweisungssätze zu, nicht ADRs, und ihre §Was hier NICHT entschieden ist nimmt fremde
  Artefakte ausdrücklich aus — sie widerspricht der Zuordnung nicht und stützt sie auch nicht; die
  Quelle ist allein Modul 8.
- **N-3 — Ausnahme 3 (`harness/conventions/`, 3 Vorkommen) trägt.** MR-041, MR-047, MR-048 liegen
  im Adaptions-Block, den [`AGENTS.md`](../../AGENTS.md) §3.8 dem Architect zuweist. Die drei
  Vorkommen sind Link-**Label**; ihr Ziel zeigt bereits auf
  `…/observations/BEO-ALL/adaptions-achse-1-kurzschluss/observation.md` und löst auf — die Aussage
  in §7 (*„dort steht das Linkziel bereits richtig, nur das Label ist stehengeblieben"*) ist
  nachgeprüft und trifft. Dass sie liegen bleiben, ist richtig; dass niemand sie holt, ist
  MEDIUM-5.
- **N-4 — Ausnahme 4 (`slice-188`, 1 Vorkommen) trägt.** Die Zeile zitiert wörtlich eine
  Test-Fixture; der zitierte Text existiert real:
  `git grep -n 'BEO-0' -- '*.go'` → `internal/archive/anwenden_test.go:275:
  "**Hervorgegangen:** [\`BEO-009\`](../../observations.md) · slice-176\n"` und
  `internal/archive/stub_test.go:212`. Ein Nachzug im Plan machte den Satz über den Quelltext
  falsch ([`AGENTS.md`](../../AGENTS.md) §3.7). Der Slice hat dort genau **ein** Vorkommen, vorher
  wie nachher (`git grep -c … e8cde04^ -- 'docs/plan/planning/open/slice-188*'` → 1).
- **N-5 — Die sieben Vorkommen innerhalb der Ablage sind für alle sieben korrekt behandelt.**
  Sechs liegen in `evidence/<vorgangs-id>.md`; alle sechs sind auf `origin/main` und damit
  *unveränderlich ab Merge* (`git cat-file -e origin/main:<pfad>` je Datei, sechsmal Exit 0). Das
  siebte liegt in
  [`regel-delta-zaehlt-herkunfts-kommentar-mit/observation.md`](../plan/planning/observations/BEO-ALL/regel-delta-zaehlt-herkunfts-kommentar-mit/observation.md)
  Zeile 8 — und zwar **im** Kurzbeschreibungs-Block (Zeilen 5–8, der Absatz zwischen `Sub-Area` und
  dem Dateiende), nicht daneben. Dass die Kurzbeschreibung mit unter *unveränderlich ab Anlage*
  fällt, führt [`observations/README.md`](../plan/planning/observations/README.md) §Form
  ausdrücklich (*„Bezeichnung, Sub-Area, Kurzbeschreibung"*) — die Korrektur der Plan-Prämisse
  (*„für Bezeichnung und Sub-Area"*, die Baseline-Formulierung) ist belegt und richtig. Auch die
  Datei selbst ist auf `origin/main`, war also nicht mehr „offen". **Liefer-Punkt 2 ist damit ohne
  Architect-Entscheidung beantwortbar**, und die von §4 vorgesehene Rückführung
  `in-progress → open` war nicht fällig: Die Regel ist unbedingt, und der zurückhaltende Zweig
  verlangt keinen neuen Norm-Text.
- **N-6 — Rollen-Disziplin des Commits im engen Sinn: `harness/conventions/*`, `harness/conventions.md`,
  `AGENTS.md` und `docs/plan/adr/**` sind unberührt.** `git show --stat e8cde04` führt 17 Dateien,
  keine davon in diesen Pfaden. [`AGENTS.md`](../../AGENTS.md) §3.8 und §3.4 sind gewahrt.
- **N-7 — `.claude/commands/implement-slice.md` gehört tatsächlich dem Implementer.**
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) `Accepted`,
  Festlegung 1, Anwendungstabelle: `.claude/commands/implement-slice.md` → **Implementer**,
  ablesbar am Eröffnungssatz der Datei. Die zwei geänderten Zeilen sind reiner Kennungs-Austausch;
  die mitgestrichene Zustandsangabe (*„, offen"*) ist korrekt entfallen, der Eintrag steht heute auf
  `verkörpert`. Kein Norm-Satz geändert, damit auch nicht Festlegung 2 berührt.
- **N-8 — Die Abbildung Nummer → Slug ist in allen 15 Dateien korrekt.** Token-Folgen-Vergleich
  gegen `9292a08^` (Verfahren in der Vorbemerkung); keine Fehl-Abbildung, kein ausgelassenes
  Vorkommen. In keiner der 15 angefassten Dateien steht danach noch eine dreistellige Nummer.
- **N-9 — Alle 67 Kennungs-Links tragen ein Label, das ihr Ziel deckt**, und das vierte Kommando
  aus §1 trifft **0** — die Verweis-Konvention aus
  [`observations/README.md`](../plan/planning/observations/README.md) §Zwei Verweis-Formen ist
  eingehalten. Mechanismus-Verweise (*„Drei Treffer im Register"*) zeigen weiterhin auf
  `README.md`; sie sind nicht mit-konvertiert worden.
- **N-10 — Zeitdokumente sind unangetastet.** Weder `docs/plan/planning/done/**` noch
  `docs/reviews/**` erscheinen in `git show --stat e8cde04`
  ([`ADR-0016`](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4,
  [`AGENTS.md`](../../AGENTS.md) §3.7).
- **N-11 — Der öffentliche Vertrag ist nicht berührt.** `git grep -o 'BEO-[0-9][0-9][0-9]' --
  internal/emit/templates | wc -l` → **0**; der emittierte Baum führt keine `BEO`-Kennung dieses
  Repos. Die DoD-Begründung, warum die `-c`-Form hier untauglich ist, trifft zu.
- **N-12 — [`AGENTS.md`](../../AGENTS.md) §3.3 ist nicht einschlägig:** `e8cde04` enthält keinen
  Rename (`git show --stat` zeigt ausschließlich Modifikationen und eine Neuanlage); der
  Lifecycle-Move lief in `1e68326` als reiner Move mit eigenem Nachzugs-Commit.
- **N-13 — §3.9 gewahrt.** Weder der Commit noch die neu eingesetzten Kommandos rufen eine
  Host-Toolchain: das ersetzte `awk` weicht `ls`/`head`/`wc`, die Gates laufen über `make`.
  Meine eigenen Sensoren ebenso.
- **N-14 — §3.6 im engeren Sinn:** Der Slice führt keinen neuen und keinen geänderten Wächter ein;
  es gibt darum keine rot färbende Mutation zu benennen, und `test/mutations/` ist unberührt.
  Die Zusagen dieses Slice sind Mess-Zusagen, und ihre Gegenprobe ist das jeweilige Kommando —
  gefahren, siehe Vorbemerkung.
- **N-15 — Kein Zustandsfeld hat Chronik bekommen.** Die `state.md` des berührten Registereintrags
  ist unangetastet und trägt weiterhin `offen`; das ist nach Modul 6 korrekt, denn der Ausgang
  steht dem Lese-Schritt zu. Die neue `evidence/`-Datei folgt der Form `**Vorgang:** / **Fund:**`
  und ist als Beleg-Dokument bestimmungsgemäß rückblickend.
- **N-16 — Der Register-Eintrag ist nicht vorschnell einem Ausgang zugewiesen.** §6 Risiko 4 trägt
  *weiter offen → Register*, §7 verweist den Ausgang ausdrücklich an den Lese-Schritt von
  [welle-15](../plan/planning/welle-15-re-baseline.md), und der Zähler ist nirgends als Feld
  gesetzt — er ist die Dateizahl (**4**,
  `ls docs/plan/planning/observations/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/evidence | wc -l`).
  Das ist Modul-6-konform. Der Einwand gegen diesen Beleg betrifft die **Klasse**, nicht das
  Verfahren (MEDIUM-3).
- **N-17 — Die vier §6-Risiken tragen je genau einen Ausgang aus der geschlossenen Menge**
  (dreimal *entfallen* mit Begründung, einmal *weiter offen* mit Register-Verweis). Die urteilsfreie
  Hälfte nach
  [`modul-05-planning-harness.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-05-planning-harness.md)
  §Offene Risiken ist erfüllt; die Urteils-Hälfte des vierten Ausgangs steht in MEDIUM-3, die des
  dritten in MEDIUM-5.
- **N-18 — Der Sichtungs-Schritt §8 ist am Anlage-Stand korrekt.** 41 Einträge und die fünf
  Zähler-Stände (5/3/5/4/3) treffen am Commit `d5a35ca`, der die Plan-Datei anlegt
  (`git ls-tree -d --name-only d5a35ca docs/plan/planning/observations/BEO-ALL/ | wc -l` und je
  Slug `git ls-tree --name-only d5a35ca …/evidence/ | wc -l`). Die wiederkehrende Klasse
  [`sichtungs-schritt-zitiert-falschen-zaehler-stand`](../plan/planning/observations/BEO-ALL/sichtungs-schritt-zitiert-falschen-zaehler-stand/observation.md)
  tritt hier **nicht** ein. Am heutigen Stand ist die Zahl auf 46 gewandert — das ist Alterung, kein
  Fehler; §8 liest den gemergten Stand zur Anlage.
- **N-19 — `make gates` selbst gefahren: EXIT 0.** `d-check: 807 Datei(en) geprüft, 0 Befund(e)`;
  `comment-claims: 55 Datei(en) geprueft, 0 Befund(e)`; `span-check` meldet Träger vorhanden und
  Ablageort git-ignoriert. Keine Gate-Lockerung im Diff, kein neues Gate behauptet
  ([`AGENTS.md`](../../AGENTS.md) §3.1, §3.5).

---

## Kategorie-Summary

| Kategorie | Zahl | Klassen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 5 | Rollenwechsel ohne Übergabe-Artefakt · Lerneintrag ohne Route in den Zähler · Beleg bucht unter fremde Kennung · Zahl neben nie gefahrenem Kommando · Ausgang nennt Träger, der nicht trägt |
| LOW | 3 | Zusage greift weiter als Abdeckung · Ersatz-Messung ohne Äquivalenz-Beleg · Zahl neben nie gefahrenem Kommando |
| INFO | 1 | Lerneintrag-Form trifft den Gegenstand nicht |

**Wiederkehrende Klassen für die Closure-Route** (Modul 5, dritte Quelle des Closure-Eintrags — die
Buchung ist Planner-Arbeit, nicht meine):

- *Rollenwechsel ohne Übergabe-Artefakt* →
  [`fremdes-rollen-artefakt-im-implementations-kontext`](../plan/planning/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md),
  heute **3×** und über der Schwelle. Mit diesem Slice die **vierte** Instanz und die dritte in
  drei aufeinanderfolgenden Reviews. Nach Modul 8 §Konflikt-Pfad (*„ab dem dritten gleichen
  Konflikttyp"*) und dem Steering-Loop-Zähler (1× notieren · 2× Symptom · 3× Lücke) ist die
  geschuldete Antwort ein **Träger**, keine weitere Notiz.
- *Zahl neben nie gefahrenem Kommando* →
  [`zahl-neben-nie-gefahrenem-kommando`](../plan/planning/observations/BEO-ALL/zahl-neben-nie-gefahrenem-kommando/observation.md),
  heute **3×**; MEDIUM-4 und LOW-3 sind zwei Funde **desselben** Vorgangs und damit *eine*
  Gelegenheit, kein zweites Auftreten.
- *Ausgang nennt Träger, der nicht trägt* →
  [`ausgang-nennt-traeger-der-nicht-traegt`](../plan/planning/observations/BEO-ALL/ausgang-nennt-traeger-der-nicht-traegt/observation.md),
  heute **2×**; ob MEDIUM-5 dorthin gehört oder eine eigene Kennung braucht (dort: Träger genannt
  aber untauglich, hier: kein Träger genannt), entscheidet der schreibende Lauf.
- *Lerneintrag ohne Route in den Zähler* (MEDIUM-2) und *Beleg bucht unter fremde Kennung*
  (MEDIUM-3) führt das Register bisher nicht.

---

## Verdikt

**Blockierend — 5 MEDIUM offen.** Das **Sachurteil des Slice trägt**: Der Kennungs-Nachzug ist
vollständig für die Menge, die er beansprucht, die Abbildung ist über alle 15 Dateien mechanisch
nachgeprüft und fehlerfrei, alle 67 Links tragen ein Label, das ihr Ziel deckt, das vierte Kommando
trifft null, und **jede der vier Ausnahmen hält** — einschließlich der, die der Auftrag ausdrücklich
in Zweifel zog: *„Architect-Sache trotz `Proposed`"* ist gegen `modul-08-agentenrollen.md`
§Rollen-Regeln geprüft und richtig, weil dort *„ADR-Änderung: Architect schreibt"* status-unabhängig
steht und *„Accepted-ADRs überschreibt niemand"* der **Zusatz** ist, nicht die Bedingung. Auch die
sieben Vorkommen in der Ablage sind für alle sieben korrekt eingeordnet; die Korrektur der
Plan-Prämisse über die Kurzbeschreibung ist belegt.

Blockierend sind die fünf MEDIUM, weil drei von ihnen genau das treffen, was den Slice überlebt:

- **MEDIUM-5** lässt sechs der 16 verbliebenen Vorkommen ohne Zuständigen zurück. Sie sind als
  *Übergabe* deklariert, und die Übergabe hat kein Artefakt — der Slice erledigt damit weniger, als
  seine eigene Ausnahme-Liste unterstellt.
- **MEDIUM-2** und **MEDIUM-3** treffen die Route in den Steering Loop: Ein Lerneintrag, der sich
  als *gezählt* ausweist und in keinem Register steht, und ein Beleg, der eine Kennung über die
  Schwelle trägt, deren unveränderliche Beschreibung ihn nicht deckt. Beides läuft auf die
  welle-15-Closure zu, die diese Einträge als nächstes liest.
- **MEDIUM-4** ist eine falsche Zahl ohne Kommando in genau dem Absatz, der die Vollständigkeit des
  Nachzugs beschreibt.
- **MEDIUM-1** ist die dritte Instanz derselben Rollen-Klasse in drei aufeinanderfolgenden
  Slice-Reviews. Der Schaden ist hier **noch nicht** eingetreten: `e8cde04` liegt nicht auf
  `origin/main` (`git status -sb` → *voraus 11*), die Beleg-Datei ist also noch nicht *unveränderlich
  ab Merge* — anders als im slice-185-Fall.

Kein HIGH: keine Hard Rule verletzt (§3.1, §3.3, §3.4, §3.5, §3.6, §3.7, §3.8, §3.9 einzeln
geprüft, N-6 bis N-15), keine aktive ADR verletzt, keine superseded ADR referenziert, kein stilles
Grün in einem Gate, kein halluziniertes Gate, keine Norm nur im Template-Kommentar, kein
Zustandsfeld mit Chronik. `make gates` ist selbst gefahren und grün (EXIT 0, `d-check` 807/0).

**Für den Konflikt-Pfad:** MEDIUM-1 berührt einen Rollen-Zuschnitt und ist damit kein reines
Implementations-Finding. Wird ihm widersprochen, greift
[`modul-08-agentenrollen.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-08-agentenrollen.md)
§Konflikt-Pfad als Rollen-Sequenz — drei legitime Verdikte mit Übergabe-Artefakten, nicht die
Herabstufung, weil der schreibende Lauf anderer Meinung ist. Da es die dritte Instanz ist, ist die
Sequenz nach demselben Abschnitt nicht mehr optional.

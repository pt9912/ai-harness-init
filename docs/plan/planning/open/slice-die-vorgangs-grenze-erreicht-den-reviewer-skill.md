# Slice slice-die-vorgangs-grenze-erreicht-den-reviewer-skill: Die Vorgangs-Grenze am Welle-Plan wird für den prüfenden Lauf lesbar

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die mehr beobachtet als die DoD unten: Der
Gegenstand ist **eine** Rollen-Entscheidung an **einer** Datei, und ihr Beleg ist der
`docs-check`-Lauf, der ohnehin in jeder DoD steht (Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht). Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap — auch nicht beim Abschluss.

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist der Reviewer-Skill **dieses** Repos. Was ein
emittiertes Repo an Skill-Inhalt bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet
(§1) — die zwei Ebenen tragen verschiedene Verträge.

**Bezug:**
[ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) (Festlegung 1 setzt die
Grenze, die hier lesbar wird; §Konsequenzen nennt diesen Slice als zweite Hälfte des
Übergabe-Artefakts),
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (Festlegung 1 — die
Datei gehört der Rolle, die sie ausführt; sie bestimmt den Verantwortlichen unten),
[ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) (Festlegung 1 — die Regel,
deren Nachzug den Konflikt auslöste),
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(Kennungs-Form),
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
(Setzung 2 für den Register-Stand in §8).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand ist eine Skill-Datei
der Durchsetzungsschicht).

**Verantwortlich:** Reviewer (pt9912). Der Liefergegenstand ist
`.harness/skills/reviewer.md`, und die Datei gehört nach
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 der
Rolle, die sie **ausführt**; der Planner schneidet den Slice, er schreibt ihn nicht.

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Ein prüfender Lauf, der einen vorlagengebundenen Nachzug an einem laufenden Welle-Plan
sieht, liest die Grenze aus
[ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) Festlegung 1 in seiner
eigenen Urteilsgrundlage — oder es steht begründet da, woran er sie sonst liest.

### Warum dieser Slice der Träger ist, und was ohne ihn passiert

Das Konflikt-Verdikt *„Lockerung legitim, aber undokumentiert"* trägt nach Baseline-Regelwerk
`modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz ein **zweiteiliges**
Übergabe-Artefakt — *„Folge-ADR + Erinnerungs-Slice in `next/`"*. Der erste Teil steht als
[ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md); dieser Slice ist der
zweite. Die Folgepflicht an den Reviewer ist die **einzige** aus jener Datei, für die keine andere
Quelle einen Moment nennt — die übrigen stehen unten in der Abgrenzung, jede mit ihrem Träger.

Ohne Träger bleibt die Urteilsgrundlage der prüfenden Rolle auf dem Stand vor dem Verdikt: Der
nächste vorlagengebundene Nachzug an einer `Lifecycle:`-Kopfnote wird erneut als
Rollen-Widerspruch gemeldet, und der Konflikt-Pfad läuft ein zweites Mal — er hat beim ersten Mal
drei Architect- und drei Reviewer-Runden gekostet. Nach Baseline-Regelwerk
`modul-08-agentenrollen.md` §Welche Rolle braucht welche Artefaktklasse ist genau das das Kriterium
für eine Skill-Datei: *„ohne fixierte Urteilsgrundlage driftet dasselbe Verhalten zwischen Läufen"*.

**Die Ablehnung ist ein zulässiges Ergebnis.** Wem die Datei gehört, entscheidet
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1, und
[ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) schreibt sie
ausdrücklich nicht. Dieser Slice liefert die **Adresse**, an der die Entscheidung fällt, nicht ihr
Ergebnis.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Änderung an
  [ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) und keine zweite
  Fassung ihrer Probe.** Die Datei steht auf `Accepted` und ist nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefroren; eine abgeschriebene Vier-Bedingungen-Probe
  im Skill wäre eine zweite Fassung, und zwei Fassungen derselben Regel driften.
  *Bestand bleibt bewusst stehen.*
- **Keine Korrektur an [ADR-0031](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
  Option F.** Ihre Contra-Zelle beruft sich für *„fremdes Eigentum (Planner)"* auf
  [ADR-0015](../../adr/0015-rollen-eigentum-an-norm-artefakten.md), die das nicht trägt;
  [ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Kontext hält den
  Befund fest. **Ihr Träger steht in der Folgepflicht selbst** — sie ist *fällig vor dem nächsten
  Accept-Übergang* jener Datei, und die Datei ist `Proposed`
  (`grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md`
  → `**Status:** Proposed`, kein Erwartungswert). Der Accept-Übergang verlangt nach
  [ADR-0040](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 eine
  Runde der prüfenden Rolle, und die liest die Datei gegen ihre zitierten Quellen.
  *Es wäre ein anderer Vorgang.*
- **Keine erneute Prüfung des Geltungsbereichs von
  [ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) Festlegung 1.** Ihr
  Re-Evaluierungs-Trigger 3 fragt, ob die Verengung auf den Welle-Plan noch trägt. **Sein Träger
  ist das Trigger-Audit**, das Baseline-Regelwerk `modul-06-roadmap.md` §Wellen-Closure-Prozedur
  als Schritt 2 jeder Welle-Closure für jede ADR vorschreibt; dieses Repo führt Wellen-Betrieb
  (`ls docs/plan/planning/welle-*.md | wc -l` → **3**, kein Erwartungswert).
  *Es wäre ein anderer Vorgang.*
- **Keine Eigentums-Entscheidung für ein zweites Planungs-Artefakt** — nicht für
  [`docs/plan/planning/README.md`](../README.md), nicht für die Roadmap, nicht für den Slice-Plan.
  [ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) verengt sich auf den
  Welle-Plan, und eine Skill-Zeile, die weiter reicht als ihre Quelle, wäre eine Zusage ohne
  Deckung. *Schicht-Abgrenzung.*
- **Kein Produkt-Code und keine Gate-Änderung.** `internal/`, `cmd/`, `harness/tools/` und
  [`.d-check.yml`](../../../../.d-check.yml) bleiben unberührt; die Grenze ist nach
  [ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Fitness Function
  ausdrücklich **kein** maschineller Prüfgegenstand. *Schicht-Abgrenzung.*

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die Closure-Pflichten darunter zählen nicht mit.

**Ein Liefer-Punkt:**

- [ ] **(1) Die Urteilsgrundlage der prüfenden Rolle beantwortet die Frage, ob ein
      vorlagengebundener Nachzug an einem laufenden Welle-Plan ein Rollen-Widerspruch ist** —
      entweder trägt `.harness/skills/reviewer.md` die Grenze aus
      [ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) Festlegung 1
      **als Zeiger auf die ADR** (nicht als abgeschriebene Probe, §1) und mit ihrem
      Geltungsbereich *Welle-Plan*, **oder** §7 trägt die begründete Ablehnung und benennt, woran
      der nächste prüfende Lauf die Grenze sonst liest. Geprüft am Ergebnis, nicht am Umfang:
      Beide Ausgänge erfüllen den Punkt, ein unbeantworteter nicht.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8). **Hier trägt das
      besonders:** Liefergegenstand *ist* die Urteilsgrundlage der prüfenden Rolle; der prüfende
      Lauf muss ein **anderer Kontext** sein als der schreibende (§5 Kriterium 2).
- [ ] Doku-Update: Liefer-Punkt (1) **ist** dieses Item — der Träger ist Durchsetzungs-Doku.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — **hier nicht**: Dieses
      Repo fährt Wellen-Betrieb (`ls docs/plan/planning/welle-*.md | wc -l` → **3**, kein
      Erwartungswert), also prüft sie die nächste Welle-Closure, auch für diesen Slice ohne
      Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/skills/reviewer.md` | update | die Urteilsgrundlage der prüfenden Rolle — Liefer-Punkt (1), Ausgang *Aufnahme* |
| diese Datei §7 | update | der Ausgang *begründete Ablehnung* — er hat keinen zweiten Ort |

**Kein Test-Eintrag, und das ist kein Vergessen.** Der Prüfgegenstand ist eine Urteilsgrundlage für
*inferential feedback*; sie ist nach Baseline-Regelwerk `modul-08-agentenrollen.md` §Welche Rolle
braucht welche Artefaktklasse genau deshalb eine Skill-Datei, weil ihr Urteil **nicht**
deterministisch ist. Ein Test daneben hielte den Text gegen eine zweite Fassung seiner selbst.

**Und keine Gate-Zusage.**
[ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Fitness Function stellt
fest, dass ihre Probe keinen Wächter hat und keinen bekommen kann — drei ihrer vier Bedingungen
sind ein Urteil und kein Muster. Dieser Slice ändert daran nichts und darf es in keinem Satz
behaupten.

**Reihenfolge:** erst den vorhandenen Skill gegen die Grenze lesen — trägt er sie schon, ist der
Liefer-Punkt ohne Änderung erfüllt und §7 sagt das —, dann entscheiden, dann schreiben.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **`slice-flache-welle-ist-eroeffnet-nicht-geplant` liegt in
`done/`**, und `in-progress/` trägt keinen Slice. Beobachtbar ohne Rückfrage, auf dem
**Hauptzweig**:

```sh
ls docs/plan/planning/done/ | grep -c '^slice-flache-welle-ist-eroeffnet-nicht-geplant\.md$'  # 1
ls docs/plan/planning/in-progress/ | grep -c '^slice-'                                        # 0  (WIP frei)
```

**Der Trigger ist kein Ergebnis dieses Slice** — beide Bedingungen sprechen über den Bestand
*vor* der Arbeit, die erste über einen **anderen** Slice.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): **Die Aufnahme verlangt mehr als eine
  Regel-Zeile** — etwa weil der Skill für Rollen-Eigentum noch gar keine Kategorie führt und erst
  eine Gliederungs-Stelle bekommen muss. Dann liefert dieser Slice eine **Form-Änderung** an der
  Urteilsgrundlage neben der Regel, und Form gehört vor Inhalt.
- `in-progress` → `open` (blockiert — Carveout?): **Eine Quelle spricht das Eigentum am Welle-Plan
  doch als Eigenschaft der Datei aus** — der erste Re-Evaluierungs-Trigger von
  [ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md). Dann ist die Grenze
  abgelöst statt ergänzend, und eine aufgenommene Skill-Zeile wäre falsch.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. **Der Liefer-Punkt trägt einen der zwei Ausgänge**, und `make gates` meldet Exit 0. Bei
   *Aufnahme* nennt der Umsetzungs-Commit die geänderte Stelle des Skills und den Zeiger auf
   [ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md); bei *Ablehnung*
   steht die Begründung in §7 und nennt den Träger, der die Grenze stattdessen hält.
2. **Schreibender und prüfender Lauf sind verschieden.** Der Review-Report nennt seinen geprüften
   Stand und hält fest, dass er an ihm nicht geschrieben hat — dieselbe Negativ-Aussage, die jeder
   Report dieses Repos im Kopf führt.

**Lerneintrag:** die Form entscheidet die Closure und nicht dieser Plan. Was aus
[ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) folgt, trägt bereits
eine ID und braucht keinen zweiten Anker (Baseline-Regelwerk `grundlagen-traceability.md`
§Herkunfts-Anker, Geltungsbereich); das Feld `liegt in` steht nur, wenn mit diesem Slice wirklich
eine Regel aus der 3×-Schwelle verkörpert wurde.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **(1) Der Skill bekommt eine zweite Fassung der Probe statt eines Zeigers.** Vier abgeschriebene
  Bedingungen neben einer eingefrorenen ADR sind zwei Quellen für dieselbe Regel; die ADR ist ab
  `Accepted` nur noch per Folge-ADR beweglich, der Skill jederzeit. **Gegenmittel im Plan:**
  Liefer-Punkt (1) verlangt den Zeiger ausdrücklich und schließt die abgeschriebene Probe aus (§1).
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>
- **(2) Die aufgenommene Grenze reicht weiter als ihre Quelle.**
  [ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) deckt allein den
  Welle-Plan; eine Skill-Zeile über *Planungs-Artefakte* würde einen Implementations-Nachzug an
  Roadmap oder Slice-Plan durchlassen, den keine Quelle freigibt — die gemessene Klasse
  [`BEO-ALL/zusammenfassung-staerker-als-ihre-quelle`](../observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md).
  **Gegenmittel im Plan:** Liefer-Punkt (1) nennt den Geltungsbereich als Teil der Zusage.
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>
- **(3) Derselbe Kontext schreibt und prüft.** Der Liefergegenstand gehört der prüfenden Rolle;
  fällt der schreibende Lauf mit dem prüfenden zusammen, misst der Skill sich selbst und die
  Rollen-Trennung ist formal gewahrt und materiell weg. **Gegenmittel im Plan:** §5 Kriterium 2
  macht die Verschiedenheit zur beobachtbaren Closure-Bedingung.
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
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
- **Risiken aus §6:** <jedes der drei mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <Repo **mit** Wellen-Betrieb — geprüft von der nächsten Welle-Closure, auch
  für diesen Slice ohne Wellen-Zugehörigkeit>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area: `*` (gesamtes Repo,
Kürzel `ALL`), deklariert in [`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area. Die Schwelle ≥ 2 von 3 Achsen ist erfüllt: eigene Regeln
([`AGENTS.md`](../../../../AGENTS.md) §3.8 und §3.10 zur Rollen-Grenze,
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) zum Eigentum am
Anweisungssatz), eigener Prüfbereich ([`make docs-check`](../../../../harness/sensors/docs-check.md))
und eigene Fehlermodi (eine Urteilsgrundlage, die weiter zusagt als ihre Quelle).
**`TOOLS` und `CODEX` sind geprüft und nicht berührt:** Keine Aussage über `harness/tools/` oder
`.codex/` ändert sich.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist am gemergten Stand durchgegangen —
**107** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, **kein
Erwartungswert**,
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2: ein Zähler-Stand ist eine datierte Messung); alle führen dieselbe Sub-Area `*`, die
Sichtung ist damit vollständig. Der Stand ist **vor** der Closure von
`slice-flache-welle-ist-eroeffnet-nicht-geplant` genommen, und die schreibt das Register fort —
die Zahlen unten wandern mit ihr. **Vier Treffer** berühren diesen Slice:

| Beobachtung (`BEO-ALL/<slug>`) | Zähler | Stand | wo sie diesen Slice trifft |
|---|---|---|---|
| `uebergabe-an-andere-rolle-ohne-traeger-artefakt` | 5× | offen | §1 — dieser Slice **ist** das fehlende Träger-Artefakt einer Übergabe |
| `fremdes-rollen-artefakt-im-implementations-kontext` | 9× | verkörpert | §1 — der Reviewer-Skill ist einer der zwei Träger, die ihr Ausgang ausdrücklich **nicht** deckt |
| `zusammenfassung-staerker-als-ihre-quelle` | 7× | offen | §6 Risiko 2 — eine Skill-Zeile, die weiter reicht als [ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) |
| `anweisungssatz-eigentum-ohne-quelle` | 5× | geplant | Kopf — das Feld `Verantwortlich:` beruft sich auf [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md), den bereits verkörperten Teil ihres Ausgangs |

```sh
for s in uebergabe-an-andere-rolle-ohne-traeger-artefakt \
         fremdes-rollen-artefakt-im-implementations-kontext \
         zusammenfassung-staerker-als-ihre-quelle \
         anweisungssatz-eigentum-ohne-quelle; do
  printf '%s %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" "$s"
done
```

**Keiner der vier erreicht mit diesem Slice 3×** — alle vier stehen längst darüber, zwei tragen
ihren Ausgang, zwei warten auf den Lese-Schritt der nächsten Welle-Closure.
**Ein eigener Folge-Slice entsteht aus der Sichtung also nicht.**

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas sind Greenfield; der Block trägt
eine Sub-Area.

### Sub-Area: `*` (gesamtes Repo, Kürzel `ALL`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — wem ein Rollen-Anweisungssatz gehört, steht in
  [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1; was
  eine Skill-Datei überhaupt rechtfertigt, in Baseline-Regelwerk `modul-08-agentenrollen.md`
  §Welche Rolle braucht welche Artefaktklasse; die Grenze selbst in
  [ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) Festlegung 1.
- **Phase-Reife:** Phase 4 für die Durchsetzungs-Doku — der Skill hat eine Ziel-Form und eine
  Versionszeile, sein Inhalt ist bewusst nicht bewacht
  (`grep -m1 '^modules:' .d-check.yml | tr ',' '\n' | wc -l` → **8**, kein Erwartungswert).
- **Evidenz-/Diskrepanz-Risiko:** **niedrig**. Die Quelle liegt als `Accepted`-ADR vor, der
  Gegenstand ist eine Regel-Zeile, und der Ausgang *Ablehnung* ist ausdrücklich zulässig — es gibt
  keine Inventur-Lücke, die erst sichtbar werden müsste.
- **Reconciliation-Aufwand:** keiner — GF, kein Inventur-Fund; die Datei `reconciliation.md`
  existiert in diesem Repo nicht (`ls docs/plan/planning/reconciliation.md` → Exit 2), und das
  zugehörige DoD-Item entfällt deshalb in §2. Graduation entfällt (n/a bei GF).

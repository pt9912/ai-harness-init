# Slice slice-226: Der Implementer-Anweisungssatz trägt die Plan-vor-Code-Disziplin des Stands `v6.7.2`

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — es gibt keine Closure-Bedingung, die mehr beobachtet als die DoD dieses
Slice; ein Anweisungssatz einer Rolle ist eine Datei, und sein Nachzug verlangt keinen repo-weiten
Beleg über die Slice-DoD hinaus (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle
braucht). Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist der Anweisungssatz **dieses** Repos. Die
emittierte Fassung unter `internal/emit/templates/commands/` bleibt draußen und hat einen
benannten Ausgang (§1).

**Rollen-Zuschnitt: dieser Slice läuft im Implementer-Kontext.**
[`.claude/commands/implement-slice.md`](../../../../.claude/commands/implement-slice.md) ist der
Anweisungssatz der Implementer-Rolle und gehört nach
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 der
Rolle, die ihn **ausführt**. Die Grenze der Ableitung steht in Festlegung 2 derselben ADR: Eine
bindende Aussage ohne Original in einer kanonischen Quelle fällt **nicht** unter sie — trägt ein
Posten unten eine solche Aussage, geht er als Meldung zurück und wird hier nicht geschrieben.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Abgleich läuft gegen
den committet vendored Baum, netzlos, nicht gegen `main`),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein
Gate liest, ob ein Anweisungssatz seinem Regelwerks-Modul folgt — dieser Slice behauptet dafür
keine Deckung; §6 benennt die Lücke),
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (Festlegung 1: das
Eigentum; Festlegung 2: die Grenze),
[`ADR-0044`](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) (die regierende Fassung des
Sprungs ist `v6.7.2`),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando),
[`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Aussage über die Baseline nennt ihren Mess-Tag).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand ist ein
Rollen-Anweisungssatz).

**Verantwortlich:** — (bis zur Priorisierung).

**Autor:** Planner. **Datum:** 2026-09-13.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** [`.claude/commands/implement-slice.md`](../../../../.claude/commands/implement-slice.md)
trägt die vier Plan-vor-Code-Blöcke, die `modul-09-implementierung.md` zwischen `v6.0.0` und
`v6.7.2` gewonnen hat, und führt die Kennungs-Notation der Ziel-Fassung.

### Der Gegenstand ist gemessen, nicht vermutet

Die Sendung stammt aus dem Delta-Nachweis von
[slice-224](../in-progress/slice-224-delta-nachweis-und-planungs-nachzug.md) §9, Zeile
`lab/regelwerk/modul-09-implementierung.md` — Antwort *übernommen (Übergabe)*, Ziel `Implementer`.
Was das Modul gewonnen hat, ist am lokalen Kurs-Klon gegen beide Tags zu lesen; die Zahlen wandern
mit dem Klon-Stand und sind **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

```sh
cd /Development/KI/ai-harness-course
git diff --shortstat v6.0.0..v6.7.2 -- lab/regelwerk/modul-09-implementierung.md   # 1 Datei, +35/−4
```

Vier Blöcke tragen die Pflicht, alle im Abschnitt §Minimal Agent Workflow (8 Schritte):

1. **Die Tests-Zeile bindet an die Akzeptanzkriterien-ID** der in Schritt 3 identifizierten
   Requirement-ID, statt den Text zu wiederholen — der Plan sagt damit vor dem ersten Diff, *woran*
   gemessen wird.
2. **Eine Ursache über viele gleichrangige Dateien bekommt eine Begründung, nicht eine je Datei.**
3. **Die Plan-Ausgabe in Schritt 4 nennt Out-of-Scope** — die Schritt-Hälfte der Regel, deren
   Dokument-Hälfte §1 des Slice-Plans ist; nimmt ein Lauf etwas mit, das §1 ausschließt, ist das
   eine Plan-Änderung vor dem Code, keine Zeile im Bericht danach.
4. **Der Plan lebt in §3 des Slice-Plans, nicht im Chat-Verlauf** — die Rücksprünge 5→4 und 6→4
   schreiben dort fort, es entsteht kein zweites Artefakt.

Dazu die Kennungs-Notation der Ziel-Fassung, die im Anweisungssatz an **3** Stellen in der alten
Form steht:

```sh
git grep -cE 'slice-<NNN>|welle-<NN>' -- .claude/commands/implement-slice.md   # 3
```

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein anderer Anweisungssatz.**
  [`.claude/commands/plan-welle.md`](../../../../.claude/commands/plan-welle.md) und
  [`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md) gehören dem
  Planner und sind von [slice-224](../in-progress/slice-224-delta-nachweis-und-planungs-nachzug.md)
  bereits nachgezogen; [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md)
  gehört dem Reviewer und liegt bei
  [slice-227](slice-227-reviewer-skill-nennt-den-vorhandenen-stand.md). *Es wäre ein anderer
  Vorgang einer anderen Rolle* ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).
- **Kein Posten, der in [`AGENTS.md`](../../../../AGENTS.md),
  [`harness/README.md`](../../../../harness/README.md), [`.d-check.yml`](../../../../.d-check.yml)
  oder [`harness/conventions/`](../../../../harness/conventions/) landet.** Die
  Gate-Index-Konsequenz desselben Delta-Posten — *Regel und Zeiger statt der Liste* — betrifft die
  Norm-Ebene und liegt bei [slice-225](slice-225-gate-index-steht-einmal.md), dessen §1 sie annimmt.
  *Folge-Slice übernimmt es.*
- **Nichts auf der emittierten Ebene** (`internal/emit/templates/commands/`). Sie hat einen eigenen
  Prüfbereich und einen eigenen Beleg — `make full-smoke`, nicht `make gates` —, und ihre
  Zusammensetzung entscheiden
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  und [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed).
  Gemessen trägt sie **6** Vorkommen der alten Notation
  (`git grep -cE 'slice-<NNN>|welle-<NN>' -- internal/emit/templates | awk -F: '{s+=$NF} END{print s}'`)
  und hat dafür **keinen**
  benannten Folge-Träger; das steht hier, damit die Grenze nicht als Adresse gelesen wird.
  *Schicht-Abgrenzung.*
- **Kein neuer Sensor für die Kopplung Anweisungssatz ↔ Regelwerks-Modul.** Dass keiner existiert,
  ist der Grund, warum dieser Nachzug überhaupt von Hand läuft (§6); ihn zu bauen wäre ein
  Gate-Vorgang mit eigener Erprobung und eigenem rotem Gegenbeispiel. *Es wäre ein anderer
  Vorgang.*

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

Zwei slice-eigene Punkte. Gezählt ist nur, was mit dem Umfang wächst.

- [ ] **1 — Die vier Plan-vor-Code-Blöcke stehen im Anweisungssatz, je an der Stelle, an der der
      Lauf sie braucht.** Nicht als Anhang und nicht als Zitat des Moduls: Die
      Akzeptanzkriterien-Bindung steht bei der Testdatei-Zeile der Plan-Ausgabe, die
      Out-of-Scope-Nennung bei Schritt 4, die Ein-Begründung-je-Ursache-Regel daneben, und der Satz
      *der Plan lebt in §3* bei den Rücksprüngen. Der Beleg ist ein Form-Vergleich gegen
      `.harness/baseline/v6.7.2/regelwerk/modul-09-implementierung.md` §Minimal Agent Workflow, je
      Block eine benannte Fundstelle im Anweisungssatz; ein Block ohne Fundstelle ist der Befund,
      keine Auslassung.
- [ ] **2 — Die Kennungs-Notation ist nachgezogen.** Nach dem Lauf liefert

      ```sh
      git grep -cE 'slice-<NNN>|welle-<NN>' -- .claude/commands/implement-slice.md
      ```

      keinen Treffer (EXIT 1). Die Zusage gilt dem **Prüfbereich einer Datei** und nicht dem Repo:
      Was außerhalb liegt, ist in §1 benannt und hat dort seinen Ausgang.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: kein öffentlicher Vertrag berührt — der Anweisungssatz ist Lauf-Instruktion,
      keine kanonische Quelle (Source Precedence, [`AGENTS.md`](../../../../AGENTS.md) §2).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt Wellen (`ls docs/plan/planning/welle-*.md`), sie werden deshalb von der nächsten Welle-Closure geprüft, auch für diesen Slice ohne Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.claude/commands/implement-slice.md`](../../../../.claude/commands/implement-slice.md) | update | der einzige Liefergegenstand: vier Blöcke aus Liefer-Punkt 1, Notation aus Liefer-Punkt 2 |

**Was hier bewusst fehlt:** eine Testdatei-Zeile. Der Gegenstand ist eine Markdown-Instruktion ohne
ausführbaren Pfad; der Prüfer ist der Form-Vergleich aus Liefer-Punkt 1 und der Review, nicht ein
Test. Dass dafür kein Sensor existiert, steht in §6 und nicht als behauptete Deckung hier
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-224](../in-progress/slice-224-delta-nachweis-und-planungs-nachzug.md) liegt in `done/` —
ablesbar an `ls docs/plan/planning/done/slice-224-*.md` auf dem Hauptzweig. Beobachtbar ohne
Rückfrage, und **kein Ergebnis dieses Slice**: Der Nachweis steht in keiner DoD-Zeile von §2. Der
Trigger ist inhaltlich nötig, nicht nur sequenziell — §9 jenes Slice ist die Quelle, die den
Gegenstand dieses Slice benennt.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Einer der vier Blöcke lässt sich nicht
  an einer Stelle unterbringen, sondern verlangt eine Umgliederung des Anweisungssatzes — dann
  trägt dieser Slice die drei übrigen und die Umgliederung wird ein eigener.
- `in-progress` → `open` (blockiert — Carveout?): Ein Block trägt eine bindende Aussage, für die
  keine kanonische Quelle dieses Repos ein Original führt — dann greift
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 2, der
  Posten gehört nicht dieser Rolle, und der Slice wartet auf die Zuweisung.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) Beide Liefer-Punkte aus §2 sind belegt — je Block eine benannte
Fundstelle, und das Notations-Kommando endet mit EXIT 1 —, und `make gates` ist grün. (2) Der
Review-Report zu diesem Slice liegt unter `docs/reviews/` und trägt keinen blockierenden Befund.
Dazu der Lerneintrag in §7 und für jedes Risiko aus §6 ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Nachzug hat keinen Wächter.** Kein Modul aus `modules:` der
  [`.d-check.yml`](../../../../.d-check.yml) hält einen Anweisungssatz gegen sein Regelwerks-Modul,
  und `make comment-claims` führt `.claude/commands/` nicht in seinem Prüfbereich
  ([`harness/README.md`](../../../../harness/README.md) §Sensors). Ein vergessener Block bleibt
  grün. — **Ausgang:** offen bis zur Closure.
- **Der Lauf ändert den Anweisungssatz, unter dem er selbst läuft.**
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 weist
  genau das dieser Rolle zu, und §Der Anlass, gemessen derselben ADR führt den Gegenfall als
  Fehlannahme. Das Risiko ist nicht das Schreiben, sondern die stille Erweiterung: ein Block, der
  über den Delta-Posten hinaus Norm setzt (Festlegung 2). Register-Stand der Klasse
  `fremdes-rollen-artefakt-im-implementations-kontext`: **8×**
  (`ls docs/plan/planning/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/evidence/*.md | wc -l`,
  kein Erwartungswert). — **Ausgang:** offen bis zur Closure.
- **Die Sendung könnte bis zum Start altern.** Zwischen dem Schnitt dieses Plans und seiner
  Ausführung kann ein weiterer Baseline-Sprung liegen; dann misst Liefer-Punkt 1 gegen einen Stand,
  den `.harness/baseline/` nicht mehr führt. Register-Stand der Klasse
  `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`: **5×**
  (`ls docs/plan/planning/observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/evidence/*.md | wc -l`)
  — über der Schwelle, und der Lese-Schritt liegt bei der nächsten Welle-Closure. Der Beleg gegen
  das Altern ist die Form der DoD: Sie nennt den Baum, nicht den Tag-String allein. — **Ausgang:**
  offen bis zur Closure.

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
  — liegt in `<…>`. Auslöser: `<BEO-ALL/<slug>>`.
  *(Wurde mit diesem Slice nichts verkörpert, entfällt die Teil-Zeile `— liegt in …` ersatzlos.)*
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
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
§Modus-Deklaration pro Sub-Area. Die Schwelle ≥ 2 von 3 Achsen ist erfüllt: eigener
Konventions-Bestand (Rollen-Eigentum als Norm-Achse), eigener Prüfbereich (der Anweisungssatz als
Lauf-Instruktion) und eigene Fehlermodi (Instruktion driftet gegen das Regelwerks-Modul).
**`TOOLS` ist nicht berührt** — der Anweisungssatz nennt `harness/tools/`-Ziele, setzt aber keine
Aussage über sie; **`CODEX` ebenso wenig** — `.codex/` führt allein den SessionStart-Injektor und
keinen Command. Pfad-Berührung allein genügt nicht.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist am gemergten Stand durchgegangen
— **99** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, **kein
Erwartungswert**); alle führen dieselbe Sub-Area `*`, die Sichtung ist damit vollständig. **Vier
Treffer** berühren diesen Slice:

| Beobachtung (`BEO-ALL/<slug>`) | Zähler | Stand |
|---|---|---|
| `fremdes-rollen-artefakt-im-implementations-kontext` | 8× | verkörpert |
| `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` | 5× | offen |
| `anweisungssatz-eigentum-ohne-quelle` | 5× | geplant |
| `uebergabe-an-andere-rolle-ohne-traeger-artefakt` | 3× | offen |

```sh
for s in fremdes-rollen-artefakt-im-implementations-kontext \
         folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht \
         anweisungssatz-eigentum-ohne-quelle \
         uebergabe-an-andere-rolle-ohne-traeger-artefakt; do
  printf '%s %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" "$s"
done
```

**Drei der vier stehen über der Schwelle und haben ihren Ausgang bereits** — dieser Slice löst
keinen davon aus und weist keinen zu: `fremdes-rollen-artefakt-im-implementations-kontext` ist in
[`AGENTS.md`](../../../../AGENTS.md) §3.10 verkörpert, `anweisungssatz-eigentum-ohne-quelle` in
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) und für seine zwei
übrigen Teile auf `slice-151`/`slice-152` geplant. Die zwei übrigen Zähler-Stände gehören ins
Kriterium *Evidenz-/Diskrepanz-Risiko* unten; den Ausgang weist der Lese-Schritt der nächsten
Welle-Closure zu, nicht diese Planung.

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas sind Greenfield; der Block trägt
eine Sub-Area.

### Sub-Area: `*` (gesamtes Repo, Kürzel `ALL`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch für die Eigentums-Frage, niedrig für den Inhalt: Wer den
  Anweisungssatz schreibt, steht in
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md); **was** er tragen
  muss, steht in keinem Adaptions-Eintrag — die Quelle ist das Regelwerks-Modul selbst, und der
  Abgleich ist Handarbeit.
- **Phase-Reife:** Phase 4 für den Anweisungssatz (Form steht, wird pro Sprung nachgezogen, kein
  Sensor), Phase 2 für die Kopplung an das Modul — sie hat eine erprobte Prozedur und **keinen**
  Prüfer.
- **Evidenz-/Diskrepanz-Risiko:** mittel. Die Diskrepanz läuft zwischen Regelwerks-Modul und
  Instruktion, und sie fällt nur auf, wenn jemand beide nebeneinanderlegt —
  `uebergabe-an-andere-rolle-ohne-traeger-artefakt` (3×) ist genau der Fall, aus dem dieser Slice
  entstand: Die Sendung hatte bis zu seinem Schnitt keinen Empfänger.
  `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` (5×) ist die zweite Richtung — dieser
  Plan altert gegen den nächsten Sprung, und §6 führt es als Risiko.
- **Reconciliation-Aufwand:** keiner — GF, kein Inventur-Fund im Sinne des
  Reconciliation-Registers (die Datei existiert in diesem Repo nicht; das DoD-Item entfällt).
  Graduation entfällt (n/a bei GF). Der Trigger, der die Kopplungs-Achse über Phase 2 hebt, ist ein
  Sensor, der einen Anweisungssatz gegen sein Regelwerks-Modul hält — er existiert nicht, und §1
  schließt seinen Bau ausdrücklich aus.

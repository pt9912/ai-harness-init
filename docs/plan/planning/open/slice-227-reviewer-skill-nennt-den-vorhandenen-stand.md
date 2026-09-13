# Slice slice-227: Der Reviewer-Skill nennt den Baseline-Stand, der im Baum liegt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — es gibt keine Closure-Bedingung, die mehr beobachtet als die DoD dieses
Slice; ein Re-Pin einer Skill-Datei verlangt keinen repo-weiten Beleg über die Slice-DoD hinaus
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht). Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist die Skill-Datei **dieses** Repos. Was ein
emittiertes Repo als Reviewer-Skill bekommt, entscheidet die Tool-Ebene und nicht dieser Slice
(§1).

**Rollen-Zuschnitt: dieser Slice läuft im Reviewer-Kontext.**
[`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) ist der Anweisungssatz der
Reviewer-Rolle und gehört nach
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 der
Rolle, die ihn **ausführt** — dort ist es der Baseline-Präzedenzfall selbst (*„R aktualisiert
Skill-Datei"*). Die Grenze der Ableitung steht in Festlegung 2: Eine bindende Aussage ohne Original
in einer kanonischen Quelle fällt **nicht** unter sie.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Abgleich läuft gegen
den committet vendored Baum, netzlos),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein
Gate liest den Kopf-Pin einer Skill-Datei — dieser Slice behauptet dafür keine Deckung; §6 benennt
die Lücke),
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

**Ziel:** Der Kopf-Pin von [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md)
nennt den Stand, den `.harness/baseline/` führt, und das Delta seines gepinnten Abschnitts ist mit
einer der zwei Antworten — *übernommen* oder *schon erfüllt* — beantwortet.

### Der Befund ist eine Messung, keine Vermutung

Der Kopf pinnt einen Stand, den der Baum nicht mehr führt; die Werte wandern mit dem Baum und sind
**keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

```sh
sed -n '4p' .harness/skills/reviewer.md   # **Baseline:** Agents-Regelwerk v6.0.0 (Kurs-Welle 116), …
ls .harness/baseline/                     # v6.7.2
```

**Was der Pin zusagt, ist eng — und genau das macht ihn beantwortbar.** Er nennt Modul 10
§Ziel-Form: Reviewer-Skill (Output-Schema, Kategorien-Semantik, Report-Pflicht,
Pflicht-Kontext-Eingang). Der gepinnte Abschnitt hat sich zwischen den zwei Ständen allein in der
Kennungs-Notation des Herkunfts-Ankers bewegt; der neue Absatz über die maschinelle
**Deckungs**-Prüfung steht in §Harness-Einordnung, also außerhalb des Pins:

```sh
cd /Development/KI/ai-harness-course
diff <(git show v6.0.0:lab/regelwerk/modul-10-review-harness.md | sed 's/[[:space:]]\+/ /g; s/ *| */|/g') \
     <(git show v6.7.2:lab/regelwerk/modul-10-review-harness.md | sed 's/[[:space:]]\+/ /g; s/ *| */|/g')
git diff --name-only v6.0.0..v6.7.2 -- lab/templates/.harness/   # leer — die Ziel-Form selbst ist unverändert
```

Die Ziel-Form `reviewer.template.md` ist über das Delta **byte-gleich**, und dieser Slice zieht
daraus ausdrücklich **keinen** Schluss über die Regel: Die Frage ist, ob unser Bestand die Regel
trägt, nicht ob die Vorlage sich bewegt hat (Register-Klasse
`byte-gleichheit-als-aussage-ueber-die-regel-gelesen`, §8).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine inhaltliche Änderung an der HIGH-Liste, am Output-Schema oder an der
  Kategorien-Semantik über das Delta hinaus.** Der Slice zieht einen Stand nach; eine neue
  Review-Regel wäre eine Verschärfung mit eigenem Anlass und eigenem Steering-Loop-Weg
  ([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)).
  *Es wäre ein anderer Vorgang.*
- **Kein anderer Anweisungssatz.**
  [`.claude/commands/implement-slice.md`](../../../../.claude/commands/implement-slice.md) liegt bei
  [slice-226](slice-226-implementer-anweisungssatz-zieht-nach.md), die zwei Planner-Commands sind von
  [slice-224](../in-progress/slice-224-delta-nachweis-und-planungs-nachzug.md) nachgezogen. *Es wäre
  ein anderer Vorgang einer anderen Rolle*
  ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).
- **Keine Aktivierung des d-check-Moduls `reviews`.** Der Absatz, den `modul-10-review-harness.md`
  mit diesem Delta gewinnt, nennt es als Werkzeug-**Beispiel** für die Deckungs-Prüfung, nicht als
  Pflicht; ob dieses Repo es einschaltet, ist eine Gate-Aktivierung mit eigener Erprobung und
  eigenem rotem Gegenbeispiel und liegt bei
  [slice-213](slice-213-review-report-laeuft-in-der-tabellen-form.md) und
  [slice-225](slice-225-gate-index-steht-einmal.md). *Folge-Slice übernimmt es.*
- **Keine Rückschrift der Versionierungs-Historie im Kopf-Kommentar.** Sie ist Chronik von Beruf
  und wird fortgeschrieben, nicht umgeschrieben — die Skill-Datei versioniert nach Modul 10, statt
  zu überschreiben. *Bestand bleibt bewusst stehen.*

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

Zwei slice-eigene Punkte. Gezählt ist nur, was mit dem Umfang wächst.

- [ ] **1 — Der Kopf-Pin nennt einen Stand, den der Baum führt.** Nach dem Lauf nennt die
      `**Baseline:**`-Zeile denselben Tag, den `ls .harness/baseline/` ausgibt, und die
      Kurs-Welle, die `sed -n '3p' .harness/baseline/<tag>/regelwerk/README.md` nennt. Die
      Versions-Zeile darüber ist erhöht, und der Kopf-Kommentar bekommt **einen** neuen Absatz
      nach dem Muster der vorhandenen: was sich im gepinnten Abschnitt real bewegt hat, gemessen
      statt angenommen.
- [ ] **2 — Das Delta des gepinnten Abschnitts trägt eine der zwei Antworten.** Für jede Änderung,
      die der normalisierte Volltext-Vergleich aus §1 **innerhalb** von Modul 10 §Ziel-Form:
      Reviewer-Skill zeigt, steht *übernommen* oder *schon erfüllt* mit Beleg — im Kopf-Kommentar,
      nicht in einem zweiten Dokument. Eine Änderung ohne Antwort ist der Befund, nicht eine
      Auslassung. **Der Vergleich läuft ohne Diff-Filter** (Register-Klasse
      `beleg-filter-entfernt-die-zeilenklasse-die-den-beleg-traegt`, §8): Ein Filter über dem Diff
      nimmt genau die Tabellen- und Listenzeilen mit, in denen dieses Modul seine Pflichten führt.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: kein öffentlicher Vertrag berührt — die Skill-Datei ist Urteilsgrundlage einer
      Rolle, keine kanonische Quelle (Source Precedence, [`AGENTS.md`](../../../../AGENTS.md) §2).
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
| [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) | update | der einzige Liefergegenstand: Kopf-Pin und Versions-Zeile aus Liefer-Punkt 1, Delta-Antwort aus Liefer-Punkt 2 |

**Was hier bewusst fehlt:** eine Zeile für `.harness/baseline/**`. Der Baum ist hier
**Mess-Grundlage**, nicht Gegenstand; getauscht hat ihn
[slice-223](../done/slice-223-baum-tausch-v672-pins-ziehen.md).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-224](../in-progress/slice-224-delta-nachweis-und-planungs-nachzug.md) liegt in `done/` —
ablesbar an `ls docs/plan/planning/done/slice-224-*.md` auf dem Hauptzweig. Beobachtbar ohne
Rückfrage, und **kein Ergebnis dieses Slice**: Weder Kopf-Pin noch Delta-Antwort stehen in einer
DoD-Zeile von §2 jenes Slice — sein §9 erzeugt für diese Datei ausdrücklich **keine** Zeile, und
genau das ist der Anlass hier.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Vergleich zeigt im gepinnten
  Abschnitt eine Änderung, die eine **inhaltliche** Anpassung der HIGH-Liste oder des
  Output-Schemas verlangt — dann trägt dieser Slice den Pin und die Anpassung wird ein eigener,
  weil §1 sie ausschließt.
- `in-progress` → `open` (blockiert — Carveout?): Der Baum führt beim Start einen anderen Stand
  als heute, und die Antwort auf einen Delta-Posten verlangt eine Entscheidung, die keine Quelle
  dieses Repos trägt — dann geht die Messung zurück an den Auftraggeber und der Slice wartet.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) `sed -n '4p' .harness/skills/reviewer.md` nennt den Tag, den
`ls .harness/baseline/` ausgibt, jede Änderung im gepinnten Abschnitt trägt eine Antwort, und
`make gates` ist grün. (2) Der Review-Report zu diesem Slice liegt unter `docs/reviews/` und trägt
keinen blockierenden Befund. Dazu der Lerneintrag in §7 und für jedes Risiko aus §6 ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Kopf-Pin hat keinen Wächter, und deshalb ist er überhaupt veraltet.** Kein Modul aus
  `modules:` der [`.d-check.yml`](../../../../.d-check.yml) hält eine Versions-Aussage gegen den
  vendored Baum — [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline stellt
  dieselbe Lücke für das Feld `Stand:` ausdrücklich fest. Nach diesem Slice stimmt der Pin und
  veraltet beim nächsten Sprung wieder. — **Ausgang:** offen bis zur Closure.
- **Der Lauf ändert den Anweisungssatz, unter dem die Review-Rolle läuft.**
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 weist
  genau das dieser Rolle zu; das Risiko ist die stille Erweiterung über den Delta-Posten hinaus
  (Festlegung 2), nicht das Schreiben. Register-Stand der Klasse
  `fremdes-rollen-artefakt-im-implementations-kontext`: **8×**
  (`ls docs/plan/planning/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/evidence/*.md | wc -l`,
  kein Erwartungswert) — und seine `state.md` nennt den Reviewer-Skill namentlich als eines der
  zwei Artefakte, die seine Verkörperung **nicht** deckt. — **Ausgang:** offen bis zur Closure.
- **Der Pin wandert, bevor der Slice läuft.** Liegt beim Start ein neuerer Stand im Baum, misst
  Liefer-Punkt 2 gegen ein anderes Delta als das hier beschriebene. Register-Stand der Klasse
  `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`: **5×**
  (`ls docs/plan/planning/observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/evidence/*.md | wc -l`).
  Die DoD ist dagegen gehärtet: Sie nennt `ls .harness/baseline/` als Quelle des Tags, nicht einen
  Tag-String. Die **Delta-Basis** in §1 ist es nicht — sie nennt `v6.0.0..v6.7.2` ausdrücklich und
  müsste dann neu gelesen werden. — **Ausgang:** offen bis zur Closure.

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
Konventions-Bestand (Rollen-Eigentum als Norm-Achse), eigener Prüfbereich (die Skill-Datei als
Urteilsgrundlage) und eigene Fehlermodi (Pin altert gegen den Baum). **`TOOLS` ist nicht berührt**
— kein Posten bewegt eine Aussage über `harness/tools/`; **`CODEX` ebenso wenig** — `.codex/` führt
keinen Skill.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist am gemergten Stand durchgegangen
— **99** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, **kein
Erwartungswert**); alle führen dieselbe Sub-Area `*`, die Sichtung ist damit vollständig. **Fünf
Treffer** berühren diesen Slice:

| Beobachtung (`BEO-ALL/<slug>`) | Zähler | Stand |
|---|---|---|
| `fremdes-rollen-artefakt-im-implementations-kontext` | 8× | verkörpert |
| `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` | 5× | offen |
| `uebergabe-an-andere-rolle-ohne-traeger-artefakt` | 3× | offen |
| `byte-gleichheit-als-aussage-ueber-die-regel-gelesen` | 2× | offen |
| `beleg-filter-entfernt-die-zeilenklasse-die-den-beleg-traegt` | 1× | offen |

```sh
for s in fremdes-rollen-artefakt-im-implementations-kontext \
         folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht \
         uebergabe-an-andere-rolle-ohne-traeger-artefakt \
         byte-gleichheit-als-aussage-ueber-die-regel-gelesen \
         beleg-filter-entfernt-die-zeilenklasse-die-den-beleg-traegt; do
  printf '%s %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" "$s"
done
```

**Zwei der fünf sind der Grund, warum dieser Slice so geschnitten ist**, und keiner wird hier
ausgelöst: `uebergabe-an-andere-rolle-ohne-traeger-artefakt` (3×) benennt die Sendung ohne
Empfänger — dieser Plan **ist** der Empfänger; `byte-gleichheit-als-aussage-ueber-die-regel-gelesen`
(2×) und `beleg-filter-entfernt-die-zeilenklasse-die-den-beleg-traegt` (1×) sind die zwei Weisen,
auf die Liefer-Punkt 2 fehlgehen kann, und stehen deshalb wörtlich in ihm.
`fremdes-rollen-artefakt-im-implementations-kontext` steht über der Schwelle und hat seinen Ausgang
bereits ([`AGENTS.md`](../../../../AGENTS.md) §3.10, `seit welle-15`); den Ausgang der übrigen weist
der Lese-Schritt der nächsten Welle-Closure zu, nicht diese Planung.

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas sind Greenfield; der Block trägt
eine Sub-Area.

### Sub-Area: `*` (gesamtes Repo, Kürzel `ALL`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch für die Eigentums- und die Versionierungs-Frage (Modul 10
  verlangt Versionieren statt Überschreiben, und die Datei führt diese Kette seit ihrer ersten
  Fassung), niedrig für die Kopplung Pin ↔ Baum: Sie steht in keinem Adaptions-Eintrag und in
  keinem Modul der Gate-Config.
- **Phase-Reife:** Phase 4 für die Skill-Datei (Form steht, Versionierung gelebt, Ziel-Form
  referenziert statt kopiert), Phase 2 für den Pin — erprobte Prozedur, **kein** Sensor.
- **Evidenz-/Diskrepanz-Risiko:** mittel. Die Diskrepanz läuft zwischen Kopf-Pin und Baum und ist
  mit einem Zweizeiler messbar; teurer ist die zweite Richtung — ein Pin, der stimmt, während der
  gepinnte Abschnitt unbeantwortet blieb. Dagegen steht Liefer-Punkt 2 und der ausdrückliche
  Verzicht auf den Byte-Gleichheits-Schluss.
- **Reconciliation-Aufwand:** keiner — GF, kein Inventur-Fund im Sinne des
  Reconciliation-Registers (die Datei existiert in diesem Repo nicht; das DoD-Item entfällt).
  Graduation entfällt (n/a bei GF). Der Trigger, der die Pin-Achse über Phase 2 hebt, ist ein
  Versions-Sensor, der jeden Baseline-Pin des Repos gegen das Feld `Stand:` hält — er existiert
  nicht, und [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline benennt genau
  diese Lücke.

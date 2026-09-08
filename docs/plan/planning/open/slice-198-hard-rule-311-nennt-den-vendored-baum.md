# Slice slice-198: §3.11 nennt den vendored Baum — ein `<tag>`-gescoptes Verzeichnis ist nicht ortsfest

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Slice ändert **einen** Absatz einer Hard Rule; sein Beleg steht
vollständig in seiner eigenen DoD, und es gibt keine repo-weite Bedingung, die darüber hinaus etwas
beobachtete (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) (die
Architect-Folgepflicht, *fällig mit der Annahme dieser ADR* — sie stellt die Aufgabe und schreibt
die Regel ausdrücklich **nicht**),
[`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md),
[`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(die drei Entscheidungen, die [`AGENTS.md`](../../../../AGENTS.md) §3.11 heute verallgemeinert —
die Schärfung darf keine von ihnen einschränken),
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (eine Verschärfung
gegenüber der Baseline braucht die Prüfung, ob sie eine Abweichung ist oder eine Lücke füllt)

**Berührte Spec-Stellen:** `—`. Eine Hard Rule ist kein Spec-Stratum; sie bindet den Lauf, nicht das
Produkt.

**Verantwortlich:** — (bis zur Priorisierung; die Arbeit ist **Architect**-Arbeit, nicht
Implementer-Arbeit — [`AGENTS.md`](../../../../AGENTS.md) §3.8 gibt Hard Rules und Adaptions-Block
dem Architect).

**Autor:** Planner. **Datum:** 2026-09-07.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** [`AGENTS.md`](../../../../AGENTS.md) §3.11 nennt die Adresse in ein `<tag>`-gescoptes
Vendoring-Verzeichnis ausdrücklich als **gebundenen** Fall — die Ausnahme *„ein Verzeichnis … ist
ortsfest"* trägt für ihn nicht.

**Warum die Lücke real ist und nicht theoretisch.** §3.11 nimmt heute aus: *„ein Verzeichnis, ein
Glob, eine stehende Ablage und eine Datei, die ihren Lifecycle bereits verlassen hat, sind ortsfest
und bleiben als Pfad zulässig."* Der vendored Baum **ist** ein Verzeichnis — nach dem Wortlaut war
jede der 36 Adressen zulässig, als sie geschrieben wurde
([`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) §Warum sie überhaupt
entstehen durften). Er ist aber `<tag>`-gescopt und wird beim Bump ersetzt; die Adresse bricht
**nicht** beim Bump, sondern später, in einem Artefakt, das niemand mehr anfasst. Ohne die
Schärfung erzeugt jeder Bump den Befund-Bestand neu.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Das Referenz-Ventil und der Breiten-Wächter.** Sie sind die *heilende* Hälfte derselben
  Entscheidung und **Implementer-Artefakte**
  ([`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) §Kopplung); sie liegen
  als [slice-197](slice-197-eingefrorene-baseline-adresse-bekommt-ihr-ventil.md), und diese Kennung
  nimmt den Punkt an. **Beide Hälften in einem Lauf hieße, das Artefakt einer anderen Rolle im
  eigenen Kontext zu schreiben** — die Klasse
  [`BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext`](../observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md),
  wegen der [`AGENTS.md`](../../../../AGENTS.md) §3.8 existiert.
- **Der Bestand der 36 Adressen.** Er ist eingefroren und kein Arbeitsauftrag; die Schärfung bindet
  die Adresse, die **geschrieben** wird — derselbe Cutoff-Zuschnitt, den §3.11 heute schon führt.
- **Ein Sensor auf die neue Aussage.** Kein Modul des Doku-Gates hält Status und Adress-Form
  zusammen, und `make mutate` kennt keine Fehlschlag-Form dafür — die Lücke benennt §3.11 für sich
  selbst bereits. Einen zu bauen wäre eine eigene Fähigkeit mit eigener Bezugsmenge, kein Nachzug an
  einem Absatz.
- **Ein Adaptions-Eintrag.** Ob die Schärfung einer ist, entscheidet die Prüfung in DoD 2 — sie
  vorwegzunehmen hieße, das Ergebnis in die Aufgabe zu schreiben.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **§3.11 führt die `<tag>`-gescopte Vendoring-Adresse als gebundenen Fall.** Die
      Ortsfestigkeits-Ausnahme wird dafür ausdrücklich aufgehoben: Ein Verzeichnis, dessen Name ein
      Tag trägt, das der nächste Bump ersetzt, ist **nicht** ortsfest. Die Zitier-Form, die an
      seine Stelle tritt, steht in der Ziel-Fassung und wird von dort übernommen statt erfunden —
      `v6.5.0` · `grundlagen-harness-dateien.md` §harness/README.md als Einstiegspunkt: *„Eine
      Stelle der vendored Baseline heißt Tag **und** Pfad in Inline-Code, nicht als Link."*
      **Was die Schärfung nicht darf:** eine der drei Entscheidungen einschränken, die §3.11 heute
      verallgemeinert, oder eine der übrigen Ortsfestigkeits-Ausnahmen (Glob, stehende Ablage,
      Datei außerhalb ihres Lifecycle) mit abräumen.
- [ ] **Der Eintrags-Bedarf ist geprüft und beantwortet, nicht angenommen.** Gemessen gegen den
      adoptierten Stand — den Tag nennen, gegen den gemessen wurde
      ([`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)):
      Führt die Baseline diese Aussage bereits, ist die Schärfung eine **Anwendung** und bekommt
      **keinen** Eintrag im Adaptions-Block
      ([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)); führt sie sie
      nicht, ist zu entscheiden, ob eine Lücke gefüllt oder abgewichen wird. Beide Ausgänge sind
      zulässig, **kein Ausgang ist es nicht** — eine Verschärfung ohne diese Prüfung ist genau die
      Klasse, die [`AGENTS.md`](../../../../AGENTS.md) §3.8 §Begründung als gemessenen Anlass
      führt.
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
| [`AGENTS.md`](../../../../AGENTS.md) §3.11 | update | der gebundene Fall und die Zitier-Form (Liefer-Punkt 1) |
| [`harness/conventions.md`](../../../../harness/conventions.md) + [`harness/conventions/`](../../../../harness/conventions/) | update **oder nicht** | hängt am Ausgang von Liefer-Punkt 2; **kein** Eintrag ist ein zulässiger Ausgang |

**Commit-Zuschnitt.** Ein Commit, der **ausschließlich** Architect-Artefakte berührt und die Rolle
in seiner Message nennt — [`AGENTS.md`](../../../../AGENTS.md) §3.8, nachträglich an
`git log --stat` ablesbar.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **[`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md)
steht auf `Accepted`** — beobachtbar an
`grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md`. Die
Folgepflicht ist damit fällig; die Bedingung ist am Tag dieses Plans erfüllt und steht hier als
Bedingung, nicht als ihr heutiger Wert.

**Keine Reihenfolge-Bedingung gegen
[slice-197](slice-197-eingefrorene-baseline-adresse-bekommt-ihr-ventil.md).** Die zwei sind
unabhängig: Dieser hier verhindert **neue** Adressen, jener räumt die **bestehenden**. Wer sie
koppelte, machte aus zwei einzeln lieferbaren Slices ein Paar, das aufeinander wartet.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Prüfung aus Liefer-Punkt 2
  ergibt, dass die Schärfung mehrere Ortsfestigkeits-Ausnahmen zugleich berührt — dann ist es keine
  Ergänzung eines Falls mehr, sondern eine Neufassung der Ausnahme-Liste, und die gehört einzeln
  geschnitten.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Schärfung eine bestehende
  `Accepted`-Entscheidung einschränken würde. Eine Hard Rule, die eine ADR verengt, ist keine
  Verschärfung, sondern ein Widerspruch — der Weg ist dann eine Folge-ADR mit `Supersedes`, nicht
  ein Absatz in §3.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. §3.11 nennt den Fall, und `make gates` ist grün — mit gültigem Stempel über dem Baum, der die
   Closure trägt.
2. Der Commit berührt außer Architect-Artefakten nichts und nennt die Rolle; beobachtbar an
   `git show --stat` des Commits.

**Lerneintrag** in einer der drei Formen (geschärfte Regel · neuer Sensor · benannte Spec-Lücke).
Die Form steht hier fest — es *ist* eine geschärfte Regel —, ihr Inhalt nicht: Was genau der
nächste Bump davon hat, misst erst der Re-Evaluierungs-Trigger von
[`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) (*„Die drei Deklarationen
sind vor dem Tausch zu messen und danach erneut"*).

**Den Abschluss schreibt der Planner** ([`AGENTS.md`](../../../../AGENTS.md) §3.10), nicht der
Architect-Lauf, der die Regel geschrieben hat.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Schärfung bleibt ohne Wächter, und das ist ihre bekannte Lage — nicht ihr Fehler.** §3.11
  stellt sie für sich selbst fest: kein Modul des Doku-Gates hält Status und Adress-Form zusammen.
  Träger ist der Lauf, der den nächsten Bump plant. Der Slice darf das **benennen** und nicht als
  gedeckt ausgeben. — **Ausgang:** offen; die Closure setzt ihn.
- **Der Eintrags-Bedarf wird gegen den falschen Stand gemessen.** Genau diese Klasse ist der
  gemessene Anlass von [`AGENTS.md`](../../../../AGENTS.md) §3.8: eine Hard Rule samt
  Adaptions-Eintrag, die eine Baseline-Abweichung behauptete, die es nicht gab — gemessen gegen
  einen Tag, den zwei Releases überholt hatten, und ohne die Mess-Version zu nennen. Der Baum steht
  seit dem Tausch auf `v6.5.0`; wer gegen `v6.0.0` misst, wiederholt sie. — **Ausgang:** offen; die
  Closure setzt ihn.
- **Die Schärfung trifft eine Adress-Form, die derselbe Lauf gerade schreibt.** Die Zitier-Form der
  Ziel-Fassung verlangt Inline-Code statt Link — auch in dem Absatz, der sie einführt, und in jedem
  Plan, der ihn zitiert. Ein Absatz, der die Regel setzt und sie im eigenen Beleg bricht, ist die
  Klasse
  [`BEO-ALL/mess-zusage-trifft-das-eigene-zitat`](../observations/BEO-ALL/mess-zusage-trifft-das-eigene-zitat/observation.md).
  — **Ausgang:** offen; die Closure setzt ihn.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area, `*` (`ALL`). Eine Hard Rule
gilt repo-weit; `harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`) sind als Pfade nicht berührt.
Eine feinere Aufteilung wäre hier Erfindung.

**Vorgelagert — offene Beobachtungen sichten:** Das Register unter
[`../observations/`](../observations/) ist durchgegangen; es führt **65** Verzeichnisse
(`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, kein Erwartungswert), alle unter
`BEO-ALL`. Diesen Vorgang betreffen — Zähler als Dateizahl unter `evidence/` abgelesen
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`; **keine
Erwartungswerte**, gelesen wird der gemergte Stand):

| Eintrag | Zähler | Stand | Bezug zu diesem Slice |
|---|---|---|---|
| `vorgeschriebener-ortswechsel-macht-adresse-tot` | 4× | verkörpert | die verkörperte Regel **ist** §3.11; dieser Slice erweitert sie um den Fall, den sie heute ausnimmt |
| `fremdes-rollen-artefakt-im-implementations-kontext` | 5× | verkörpert | der Grund, warum diese Hälfte **nicht** in [slice-197](slice-197-eingefrorene-baseline-adresse-bekommt-ihr-ventil.md) liegt — §1 erster Ausschluss |
| `mess-zusage-trifft-das-eigene-zitat` | 1× | offen | die Zitier-Form gilt für den Absatz, der sie einführt — §6 drittes Risiko |
| `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` | 1× | offen | dieselbe Fehler-Richtung eine Ebene daneben: eine Aussage über einen Stand, ohne ihn zu messen — DoD 2 verlangt den Tag |

**Kein Eintrag erreicht mit diesem Slice 3×.** Die zwei bei 4× stehen auf `verkörpert` und brauchen
keinen weiteren Ausgang; die zwei bei 1× blieben bei höchstens 2×. Alle Bezeichnungen sind
**zitiert**, nicht neu formuliert.

**Modus:** alle berührten Sub-Areas **GF** — der Begründungsblock entfällt damit nach der
Umfangs-Regel dieser Sektion.

# Slice slice-199: ADR-0038 bekommt ihre Bestätigungsrunde, und ihr Beleg einen lebenden Ort

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Beleg, den dieser Slice herstellt, ist ein Review-Report zu **einer**
Entscheidung; seine Closure-Bedingung steht vollständig in seiner eigenen DoD (Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (Option F,
mitgewählt — *„die ausstehende Bestätigungsrunde nachholen, ohne die Datei anzufassen"*; Festlegung 2
sagt, warum die vorhandene Nachmessung keiner ist),
[`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md) (die Entscheidung, deren
Acceptance-Trigger unbelegt blieb — sie ist `Accepted` und wird von diesem Slice **nicht**
angefasst, [`AGENTS.md`](../../../../AGENTS.md) §3.4),
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (Festlegung 3 stellt das
Kriterium der regierenden Fassung — das inhaltliche Maß, gegen das die Runde prüft),
[`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
[`ADR-0036`](../../adr/0036-ziel-fassung-regiert-den-sprung-v600.md) (die zwei weiteren Quellen,
die der Trigger von [`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md) nennt),
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
(bei Personalunion ist der zweite Kontext der einzige Träger einer Gegenprüfung)

**Berührte Spec-Stellen:** `—`. Der Slice stellt einen Prüf-Beleg her; er ändert keine Festlegung.
**Falls** die Runde einen blockierenden Befund gegen den Inhalt meldet, ist das der
Re-Evaluierungs-Trigger 3 von
[`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) — und dann ein
eigener Vorgang, nicht dieser (§6).

**Verantwortlich:** — (bis zur Priorisierung; die prüfende Arbeit ist **Reviewer**-Arbeit, die
Einplanung Planner-Arbeit).

**Autor:** Planner. **Datum:** 2026-09-07.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Die Bestätigungsrunde, die der Acceptance-Trigger von
[`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md) verlangt, ist **gefahren** —
in frischem Reviewer-Kontext gegen
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md),
[`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) und
[`ADR-0036`](../../adr/0036-ziel-fassung-regiert-den-sprung-v600.md) —, und ihr Beleg liegt an
einem **lebenden** Ort, den ein späterer Lauf findet.

**Was heute steht.** Der einzige Report zu jener Entscheidung schließt mit *„Nicht annahmefähig in
dieser Runde — zwei HIGH"* und stellt selbst fest, er sei der verlangte Report nicht. Zwischen ihm
und dem Accept-Commit liegt allein der Architect-Commit, der die zwei HIGH auflöst — die
Bestätigung, die der Trigger verlangt, ist damit eine **Nachmessung desselben Kontexts**, und
[`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2
verwirft sie als Beleg. Welche Reports jene Entscheidung nennen, sagt das Kommando; **eine Zahl
steht hier nicht**, und der Grund ist derselbe, den jene Entscheidung für sich selbst nennt: Der
Korpus `docs/reviews/` wächst mit jeder Runde, auch mit der, die dieser Slice liefert — eine Zahl
wäre in dem Moment falsch, in dem dieser Plan nach `done/` einfriert.

```sh
git grep -lF '0038-ziel-fassung-regiert-den-sprung-v650' -- 'docs/reviews/*.md'
```

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Accept-Zeile von [`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md).** Sie
  ist nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefroren und nennt weiterhin keinen Beleg;
  der Schaden bleibt dauerhaft. Das steht in
  [`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Option F als
  ausdrücklicher Preis — *„heilt die Accept-Zeile nicht"*. Ein Lauf, der sie doch anfasste, machte
  aus einer Entscheidung ein Arbeitsdokument.
- **Ein `Supersedes` auf jene Entscheidung.** Es setzte eine neue Entscheidung über den Sprung
  `v6.0.0` → `v6.5.0` voraus; dieser Slice prüft, er entscheidet nicht. Die Bedingung, unter der es
  wieder offensteht, ist Re-Evaluierungs-Trigger 3 von
  [`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md), und der ist ein
  eigener Vorgang.
- **Der Register-Beleg zur Klasse der unbelegten Annahme.** Er ist die **zweite**
  Planner-Folgepflicht von
  [`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) und wird bei
  einer **Closure** geschrieben, nicht von einem Prüf-Slice: Das Register wird bei der
  Slice-Closure fortgeschrieben, und der Beleg ist ein abgeschlossener Vorgang. Welche Closure ihn
  trägt und ob er in
  [`BEO-ALL/proposed-adr-annahme-ohne-repo-internen-traeger`](../observations/BEO-ALL/proposed-adr-annahme-ohne-repo-internen-traeger/observation.md)
  gehört oder in eine **eigene** Beobachtung, ist ein Urteil und steht in §6.
- **Die Klasse als Regel.** Sie ist bereits geregelt — das sind die drei Festlegungen von
  [`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md), und ihr Cutoff
  nimmt den Bestand ausdrücklich aus. Dieser Slice behandelt die **Instanz**.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **Ein Report der Reviewer-Rolle liegt unter `docs/reviews/` und prüft
      [`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md) auf Konsistenz gegen die
      drei Quellen, die ihr Trigger nennt** —
      [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md),
      [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
      [`ADR-0036`](../../adr/0036-ziel-fassung-regiert-den-sprung-v600.md). **In frischem Kontext**:
      Der Lauf, der die zwei HIGH aufgelöst hat, ist kein Träger dieser Runde
      ([`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
      Festlegung 2). Der Report nennt die zwei HIGH der ersten Runde **namentlich** und sagt je
      Befund, ob er behoben ist — sonst prüft er einen anderen Gegenstand als den, an dem die erste
      Runde blockierte.
- [ ] **Der Beleg steht an einem lebenden Ort und ist von dort auffindbar.** Die eingefrorene
      Entscheidung nimmt ihn nicht mehr auf; ohne einen benannten Ort ist die Runde gefahren und
      trotzdem verloren. **Welcher Ort es ist, entscheidet dieser Slice** — der Kandidat mit der
      besten Deckung ist `state.md` des betroffenen Register-Eintrags (veränderlich, wird
      fortgeschrieben, trägt Zustand und Beleg als auflösbaren Anker). Der Beleg nennt den Report
      als **Kennung**, nicht als Pfad, wenn der Zielort einfriert
      ([`AGENTS.md`](../../../../AGENTS.md) §3.11).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
      **Nicht zu verwechseln mit Liefer-Punkt 1:** Jener ist der Prüfgegenstand dieses Slice, dieser
      die Prüfung *des Slice*. Zwei Reports, zwei Gegenstände — fielen sie zusammen, prüfte der
      Slice sich selbst.
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
| `docs/reviews/<datum>-adr-0038-bestaetigungsrunde.md` | neu | der Beleg, den der Acceptance-Trigger verlangt (Liefer-Punkt 1) |
| der gewählte lebende Ort — Kandidat: `state.md` des betroffenen Register-Eintrags | update | der Zeiger, ohne den die Runde gefahren und trotzdem verloren ist (Liefer-Punkt 2) |
| [`docs/plan/adr/`](../../adr/) | **unberührt** | jede `Accepted`-Datei ist eingefroren ([`AGENTS.md`](../../../../AGENTS.md) §3.4); steht am Ende dieses Slice ein Diff darin, ist die Grenze aus §1 gebrochen |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **[`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
steht auf `Accepted`** — beobachtbar an
`grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md`.
Erst damit ist Option F beschlossen und die Folgepflicht fällig; die Bedingung ist am Tag dieses
Plans erfüllt und steht hier als Bedingung, nicht als ihr heutiger Wert.

**Keine Bedingung gegen den Baum-Tausch.** Der Slice prüft eine **Entscheidung**, nicht deren
Vollzug — er ist von
[slice-193](../done/slice-193-baum-tausch-v650-pins-ziehen.md),
[slice-197](../done/slice-197-eingefrorene-baseline-adresse-bekommt-ihr-ventil.md) und
[slice-198](slice-198-hard-rule-311-nennt-den-vendored-baum.md) unabhängig. **Das ist der Punkt und
kein Nebeneffekt:** Der Vollzug ist bereits gelaufen, ohne dass der Trigger belegt war; die Runde
holt den zweiten Kontext nach, den er verlangte.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Runde eine Kette weiterer Runden
  auslöst — jeder blockierende Befund verlangt nach
  [`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 eine
  **weitere** Runde. Dann ist die Kette der Gegenstand und gehört einzeln geschnitten, nicht in
  einem Slice ausgesessen.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Runde einen blockierenden Befund gegen
  den **Inhalt** von [`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md) meldet.
  Dann ist ihre Festlegung nicht nur unbelegt, sondern bestritten — Re-Evaluierungs-Trigger 3 von
  [`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) —, und die
  Antwort ist eine Architect-Entscheidung, kein weiterer Prüf-Lauf.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. Der Report aus Liefer-Punkt 1 liegt in `docs/reviews/`, nennt die zwei HIGH der ersten Runde
   namentlich und sagt je Befund, ob er behoben ist. **Ob er ohne blockierenden Befund schließt,
   ist kein Closure-Kriterium** — ein Prüf-Slice, dessen Abschluss vom Prüf-**Ergebnis** abhinge,
   erzeugte den Druck, grün zu melden. Geliefert ist die Runde, nicht ihr Ausgang.
2. Der Beleg steht am gewählten lebenden Ort und löst von dort auf — beobachtbar an
   `make docs-check` (`0 Befund(e)`) und daran, dass ein Leser des Register-Eintrags den Report
   ohne Rückfrage findet.

**Lerneintrag** in einer der drei Formen (geschärfte Regel · neuer Sensor · benannte Spec-Lücke).
Ein Kandidat steht fest: Die **Instanz** ist damit versorgt, die Frage *wo der Beleg einer Prüfung
lebt, deren Gegenstand eingefroren ist* aber allgemein — sie trifft jede künftige
Bestätigungsrunde nach
[`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2.

**Den Abschluss schreibt der Planner** ([`AGENTS.md`](../../../../AGENTS.md) §3.10), nicht der
Reviewer-Lauf, der die Runde gefahren hat.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Runde bestätigt, und der Statuswert bleibt trotzdem ohne Deckung in der Datei.** Die
  Accept-Zeile von [`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md) ist
  eingefroren; ein Leser, der nur sie liest, findet weiterhin keinen Beleg. Der Slice kann das nur
  **von außen** heilen, und wie gut das trägt, hängt allein an Liefer-Punkt 2. — **Ausgang:**
  offen; die Closure setzt ihn.
- **Der Register-Beleg gehört möglicherweise nicht in den vorhandenen Eintrag.**
  [`BEO-ALL/proposed-adr-annahme-ohne-repo-internen-traeger`](../observations/BEO-ALL/proposed-adr-annahme-ohne-repo-internen-traeger/observation.md)
  beschreibt eine Entscheidung, die auf `Proposed` **steht**, während ein anderer Vorgang ihre
  Annahme als Start-Bedingung führt — der beobachtete Fall ist ein anderer: Die Entscheidung
  **wurde** angenommen, nur ohne den Beleg, den ihr eigener Trigger verlangt.
  [`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) lässt beides
  offen (*„oder in eine eigene Beobachtung"*), und die Wahl ist ein **Urteil**: Eine Umformulierung
  in denselben Eintrag zählte zwei Klassen als eine, eine neue Kennung teilte eine Klasse in zwei.
  Der Zähler steht heute bei 1× (`ls docs/plan/planning/observations/BEO-ALL/proposed-adr-annahme-ohne-repo-internen-traeger/evidence/*.md | wc -l`,
  kein Erwartungswert). — **Ausgang:** offen; die Closure setzt ihn.
- **Die Kette wird länger als der Slice.** Meldet die Runde einen blockierenden Befund, verlangt
  [`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 die
  **nächste** Runde — und deren Befund gegebenenfalls wieder eine. Der Fall
  [`ADR-0037`](../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md) zeigt, dass solche Ketten
  hier vorkommen; jene Entscheidung führte am Stichtag 2026-09-07 **sieben** Konsistenz-Runden
  (`ls docs/reviews/*adr-0037-konsistenz-review*.md | wc -l`). **Kein Erwartungswert, und die
  Stichtags-Form ist hier Pflicht statt Vorsicht:** Eine Zahl über `docs/reviews/**` wächst mit dem
  Prüfverfahren selbst und wäre in dem Moment falsch, in dem dieser Plan nach `done/` einfriert
  ([`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) §Konsequenzen).
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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area, `*` (`ALL`). Der Gegenstand
ist eine Entscheidung und ein Prüf-Beleg; `harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`) sind
nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Das Register unter
[`../observations/`](../observations/) ist durchgegangen; es führt **65** Verzeichnisse
(`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, kein Erwartungswert), alle unter
`BEO-ALL`. Diesen Vorgang betreffen — Zähler als Dateizahl unter `evidence/` abgelesen:

| Eintrag | Zähler | Stand | Bezug zu diesem Slice |
|---|---|---|---|
| `proposed-adr-annahme-ohne-repo-internen-traeger` | 1× | offen | die nächstliegende Kennung für den beobachteten Fall — ob sie ihn trägt, ist §6 zweites Risiko |
| `uebergabe-an-andere-rolle-ohne-traeger-artefakt` | 2× | offen | die Nachmessung des auflösenden Kontexts **ist** eine Übergabe ohne Träger-Artefakt; erreicht mit diesem Slice **nicht** 3×, weil er sie behebt statt sie zu wiederholen |
| `beleg-nach-dem-ausgang-findet-keinen-leser` | 1× | offen | genau die Frage aus Liefer-Punkt 2 — ein Beleg an einem Ort, den niemand liest, ist keiner |
| `schwellen-uebertritt-ohne-zustaendige-rolle` | 2× | offen | wer die Kette aus §6 drittem Risiko abbricht, ist keiner Rolle zugewiesen |

Der Zähler-Stand jedes Eintrags ist abzulesen und nicht abzuschreiben
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`); **keine
Erwartungswerte**. Alle Bezeichnungen sind **zitiert**, nicht neu formuliert, damit das Register
sie nicht als zwei Pfade zählt.

**Kein Eintrag erreicht mit diesem Slice 3×** — vorausgesetzt, die Closure legt ihre Belege so,
wie §6 sie vorzeichnet. Trifft sie eine andere Wahl, ist der Übertritt vor dem `git mv` zu prüfen,
nicht danach.

**Modus:** alle berührten Sub-Areas **GF** — der Begründungsblock entfällt damit nach der
Umfangs-Regel dieser Sektion.

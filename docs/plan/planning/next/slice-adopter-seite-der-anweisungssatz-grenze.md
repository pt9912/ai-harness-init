# Slice slice-adopter-seite-der-anweisungssatz-grenze: Was ein erzeugtes Repo an Eigentums-Aussage über seine Anweisungssatz-Artefakte bekommt, ist entschieden

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case, der den **Gegenstand** nennt: die Adopter-Seite
der Anweisungssatz-Grenze.

**Welle:** ohne Welle. Der Gegenstand ist eine **Eigentums-Aussage**, kein Werkzeug:
[welle-emittierte-werkzeuge](../welle-emittierte-werkzeuge.md) §1 bindet ihre Mitgliedschaft an die
Frage, ob eine **vorgeschriebene Operation** im Ziel ein Werkzeug hat — eine Aussage darüber, welche
Rolle eine Datei schreiben darf, ist keine Operation, und ihr Beleg wäre kein Lauf von
[`make full-smoke`](../../../../harness/sensors/full-smoke.md). Wäre dieser Slice ein Mitglied,
müsste §1 der Welle neu gelesen werden — das ist eine Umplanung der Welle und nicht dieser Schnitt.
Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap — auch nicht beim Abschluss.

**Ebene: dieses Repo, Gegenstand ist die Emission.** Entschieden wird **was** ein erzeugtes Repo an
Aussage bekommt; die emittierte Instanz selbst gehört dem Adopter (§1).

**Bezug:**
[ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) (der
Gegenstand: Festlegung 2 (a) nimmt die Adopter-Seite aus, Folgepflicht 4 gibt ihrem Zuschnitt eine
Lifecycle-Adresse und lässt sie ausdrücklich beim Planner),
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (Folgepflicht 3 nennt
dieselbe Frage; Festlegung 1 ist der Maßstab, an dem ein Träger-Ort hängt),
[ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) (dieselbe Klausel für
ihren Gegenstand),
[ADR-0007](../../adr/0007-bootstrap-phasen.md) (Festlegung 3 klassifiziert `.claude/commands/*.md`
als `skip-if-present` über den ANPASSEN-Marker),
[ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) (Festlegung 5, letzter Absatz —
der Präzedenzfall für die Frage, wo im Ziel ein Satz hält),
[`AGENTS.md`](../../../../AGENTS.md) §3.4, §3.8, §3.10,
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
[`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand ist eine Rollen- und
Emissions-Grenze).

**Verantwortlich:** Architect (pt9912). Der Liefergegenstand ist eine **Norm-Aussage über
Eigentum** — die Klasse, die dieses Repo als Architect-ADR führt
([ADR-0015](../../adr/0015-rollen-eigentum-an-norm-artefakten.md),
[ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md),
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
[ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md), zuletzt der Gegenstand
selbst als
[ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)); die zwei
Slices derselben Klasse tragen dieselbe Besetzung —
[slice-145](../done/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md), das für genau
diesen Konflikt-Pfad direkt in `next/` abgelegt wurde, und
[slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md). Das Feld weicht damit
von der Default-Besetzung ab, die Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als
State Machine nennt (*„den Rolleninhaber der Implementer-Rolle"*) — gesetzt ist es trotzdem, weil
dieser Slice direkt in `next/` liegt und der Übergang `open`→`next`, der es nach jener Sektion
setzt, dabei übersprungen wird. Das Feld sagt *wer*, nicht *wo*: Der Zustand bleibt das Verzeichnis,
und kein Sensor prüft es.

**Autor:** Planner. **Datum:** 2026-09-15.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Für die **Adopter-Seite** aus
[ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) Festlegung
2 (a) steht an einem auflösbaren Ort, was ein **erzeugtes** Repo an Eigentums-Aussage über seine
Anweisungssatz-Artefakte bekommt — bejaht mit Träger-Ort und der Rolle, der er gehört, oder
verneint mit Grund —, und die Quelle, die die Frage bis heute ausnimmt, ist auf die Antwort hin
fortgeschrieben.

### Warum dieser Slice, und was ohne ihn passiert

Drei Entscheidungen zeigen auf denselben leeren Slot, und keine nennt einen Träger:

- [ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
  Festlegung 2 (a): *„Diese Frage bleibt **offen**, und sie liegt bei dem Slot, der die Tool-Ebene
  entscheidet"*; §Was diese Entscheidung nicht tut wiederholt es als
  *„Sie entscheidet nichts über die Adopter-Seite."*
- [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Folgepflicht 3:
  *„Ob ein erzeugtes Repo eine Eigentums-Aussage über seine Anweisungssatz-Artefakte bekommt,
  entscheidet der Slice, der die Tool-Ebene entscheidet."*
- [ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Was diese
  Entscheidung nicht tut führt dieselbe Klausel für ihren Gegenstand.

Ohne Träger beantwortet der nächste Lauf die Frage **faktisch** — die Register-Klasse
[`BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md)
beschreibt genau das, und
[ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) hängt ihren fünften
Re-Evaluierungs-Trigger an ihren Zähler. Mit der Annahme von
[ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) friert die
Ausnahme zusätzlich ein: nach
[`AGENTS.md`](../../../../AGENTS.md) §3.4 ist ihr Kern dann nur noch per Folge-ADR beweglich.

### Der Gegenstand ist gemessen, nicht vermutet

**Keine Erwartungswerte** — die Zahlen wandern mit dem Baum
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

```sh
git ls-files internal/emit/templates/ | wc -l                                    # 25 — der ganze Satz, den dieses Repo ins Ziel schreibt
git grep -c 'writeSkipIfPresent' -- internal/emit/commands.go                    #  1 — die Commands sind skip-if-present
git grep -l 'Dieser Command führt die' -- internal/emit/templates/commands/ | wc -l  # 3 — die drei Commands nennen ihre ausführende Rolle
ls internal/emit/templates/docs/plan/adr/                                        # Exit 2 — dieses Repo emittiert keine ADR
```

Drei Beobachtungen tragen den Zuschnitt, und alle drei stehen schon im Baum:

1. **Die Datei gehört nach der Annahme dem Adopter.** `.claude/commands/*.md` ist
   `skip-if-present` ([ADR-0007](../../adr/0007-bootstrap-phasen.md) Festlegung 3, dort über den
   ANPASSEN-Marker klassifiziert). Eine Aussage, die dieses Repo in die Vorlage schreibt, erreicht
   den Adopter als **Vorschlag** — ein Re-Lauf zieht an seiner Fassung nichts nach.
   [ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 5 spricht die
   Folge für dieselbe Dateiklasse verbatim aus: *„was ein Adopter dort ändert, zieht kein Re-Lauf
   nach."*
2. **Für die Frage, wo ein Satz im Ziel hält, hat dieses Repo bereits eine Antwort gefunden — eine,
   die nicht der Anweisungssatz ist.** Ebenda: *„Das Fragment ist tool-eigen und konvergent, also
   die Stelle, die ein Re-Lauf hält"* — *„ein tool-eigenes Gefäß statt eines, das dem Adopter
   gehört"*. Ob für eine Eigentums-Aussage derselbe Schluss gilt, entscheidet dieser Slice;
   gemessen ist nur, dass **beide** Möglichkeiten im Baum stehen.
3. **Der Ort, an dem dieses Repo Eigentum regelt, existiert im Ziel nicht.** Die fünf
   Eigentums-Entscheidungen leben unter [`docs/plan/adr/`](../../adr/) und im Adaptions-Block; das
   Ziel bekommt keines von beiden von hier (`ls internal/emit/templates/docs/plan/adr/` → Exit 2).
   Ein Adopter führt die Regel damit in **seiner** `harness/conventions.md` — die er aus der
   vendored Baseline kopiert und die dieses Repo nicht schreibt.

**Was gemessen nicht entschieden ist, steht hier, weil es sonst als entschieden gälte:** ob die
Antwort *„eine Aussage"* oder *„keine"* lautet, und **welcher Träger** im ersten Fall trägt. Beides
ist ein Urteil über eine Kante und kein Messergebnis
([`MR-055`](../../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)
als Selbstbindung).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Satz im emittierten Anweisungssatz und keine Änderung unter `internal/emit/`.**
  *Es wäre ein anderer Vorgang — und eine andere Rolle.* Die Festlegung ist Arbeit am **Gegenstand**
  (welche Regel gilt); ein Satz in einer emittierten Vorlage ist Arbeit am **Werkzeug** und gehört
  je Datei der Rolle, die ihren Ablauf ausführt
  ([ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) Festlegung
  1). Die Emissionsebene hat zudem einen eigenen Prüfbereich — [`make full-smoke`](../../../../harness/sensors/full-smoke.md),
  nicht `make gates` —, und ihre Zusammensetzung entscheiden
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  und
  [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed).
  **Der „ja"-Fall wird dadurch nicht zu einem „später":** Liefer-Punkt (1) verlangt, dass die
  Festlegung Träger-Ort **und** Rolle nennt — die Adresse steht dann in ihr, nicht in einem Vorsatz.
- **Keine Aussage über `.claude/agents/*.md`.** [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  Festlegung 3 nimmt die Typkarten aus, und
  [ADR-0029](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) ist dort offen
  (`grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0029-*.md` → `**Status:** Proposed`).
  [ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) §Was diese
  Entscheidung nicht tut sagt dasselbe. *Bestand bleibt bewusst stehen:* eine Antwort, die sie
  mitnähme, wäre eine zweite Fassung einer offenen Frage und liefe ihrer Quelle voraus.
- **Keine Änderung an den `Accepted`-Entscheidungen, auf die die Antwort sich stützt** —
  [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
  [ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md),
  [ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md). Ihr Kern ist nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefroren; berührt die Antwort eine von ihnen, ist die
  Fortschreibung eine Folge-ADR mit `Supersedes` und ein eigener Vorgang. *Es wäre ein anderer
  Vorgang.*
- **Kein neuer Sensor.** Kein Modul aus `modules:` der [`.d-check.yml`](../../../../.d-check.yml)
  liest Rollen-Zuordnungen, und `make mutate` kennt keine Fehlschlag-Form dafür — dieselbe Lage, die
  [ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
  §Fitness Function für sich feststellt. Einen zu bauen hieße einen Gate-Vorgang mit eigener
  Erprobung und eigenem rot gesehenem Gegenbeispiel zu behaupten
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
  *Schicht-Abgrenzung.*

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
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

**Zwei slice-eigene Punkte.** Kein Test-Eintrag: der Prüfgegenstand ist eine Norm-Aussage ohne
ausführbaren Pfad (§3).

- [ ] **1 — Die Adopter-Seite ist entschieden und trägt ihren Ausgang.** Eine Festlegung
      beantwortet die Frage aus
      [ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
      Festlegung 2 (a), und die Index-Zeile nach
      [`AGENTS.md`](../../../../AGENTS.md) §5 steht. **Beide Ausgänge erfüllen den Punkt:**
      *„Aussage"* — die Festlegung nennt den Träger, in dem die Aussage steht, **und** die Rolle,
      der er nach
      [ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
      Festlegung 1 gehört; *„keine Aussage"* — sie nennt den Grund und den Ort, an dem ein Adopter
      die Regel stattdessen führt. **Ein Ausgang, der weder das eine noch das andere nennt, erfüllt
      ihn nicht** — der Gegenstand ist die Antwort, nicht ihre Richtung.
- [ ] **2 — Die Quelle ist auf die Entscheidung hin fortgeschrieben.**
      [ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
      nimmt die Frage in Festlegung 2 (a) und in §Was diese Entscheidung nicht tut ausdrücklich
      aus; **jeder ihrer zwei Re-Evaluierungs-Zweige ist ein gültiger Ausgang:** trägt sie
      `Accepted`, ist die Fortschreibung von Festlegung 2 (a) eine Folge-ADR mit `Supersedes` und
      dem Klammer-Qualifier in der Index-Zeile
      ([`AGENTS.md`](../../../../AGENTS.md) §3.4); trägt sie `Proposed`, wird ihre §Geschichte um
      die Zeile *„Überarbeitet, weiter `Proposed`"* fortgeschrieben und Festlegung 2 (a) trägt den
      neuen Zustand. Beide Ausgänge erfüllen den Punkt, ein dritter nicht.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: Liefer-Punkt (1) **ist** dieses Item — die Festlegung und ihr Index-Eintrag
      sind der öffentliche Vertrag.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die
      Datei nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — **hier nicht**: Dieses
      Repo fährt Wellen-Betrieb (`ls docs/plan/planning/welle-*.md | wc -l`), also prüft sie die
      nächste Welle-Closure, auch für diesen Slice ohne Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| eine neue ADR unter [`docs/plan/adr/`](../../adr/) — frei ist die nächste Kennung nach `ls docs/plan/adr/ \| tail -1` | neu (per `cp` aus der vendored ADR-Vorlage), Architect, eigener Commit | Liefer-Punkt (1) — die Festlegung selbst |
| [`docs/plan/adr/README.md`](../../adr/README.md) | update (Index-Zeile), Architect | Liefer-Punkt (1) — derivatives Register desselben Originals ([ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)) |
| [ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) | update **oder** eine Folge-ADR mit `Supersedes` | Liefer-Punkt (2) — welcher der zwei Ausgänge, entscheidet der Status der Datei |
| diese Datei §7 | update | der Ausgang *„keine Aussage"* und die Register-Route haben keinen zweiten Ort |

**Kein Test-Eintrag, und das ist kein Vergessen.** Der Prüfgegenstand ist eine Norm-Aussage über
eine Rolle; ihr Wahrheitswert hängt an einer Lesart des Artefakts und nicht an einem Muster. Ein
Test daneben hielte den Text gegen eine zweite Fassung seiner selbst — dieselbe Grenze, die
[ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
§Fitness Function für ihre zwei Festlegungen zieht.

**Und keine Gate-Zusage.** Kein Modul aus `modules:` der [`.d-check.yml`](../../../../.d-check.yml)
liest Rollen-Zuordnungen, und `make mutate` kennt keine Fehlschlag-Form dafür; dieser Slice darf in
keinem Satz eine Deckung behaupten, die er nicht hat
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

**Commit-Zuschnitt nach Rollen
([`AGENTS.md`](../../../../AGENTS.md) §3.8 und §3.10).** Ein Architect-Commit für die Festlegung
samt Index-Zeile und — falls `Proposed` — für die Fortschreibung von
[ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md); die
Message nennt die Rolle. Danach die Planner-Closure in ihrem eigenen Commit. Ein Review-Durchgang
trägt keinen Commit (die Konsistenz-Prüfung ist Voraussetzung, kein Artefakt).

**Reihenfolge:** erst den Bestand gegen die Frage lesen — die drei zitierten Klauseln und die zwei
Träger-Kandidaten —, dann entscheiden, dann schreiben. Ein Lauf, der zuerst schreibt und danach
entscheidet, hat die Frage faktisch beantwortet (§1).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-174-archivierung-emittieren](../in-progress/slice-174-archivierung-emittieren.md) liegt in
`done/`, und `in-progress/` trägt keinen Slice. Beobachtbar ohne Rückfrage, auf dem
**Hauptzweig**:

```sh
ls docs/plan/planning/done/ | grep -c '^slice-174-archivierung-emittieren\.md$'   # 1
ls docs/plan/planning/in-progress/ | grep -c '^slice-'                             # 0  (WIP frei)
```

**Der Trigger ist kein Ergebnis dieses Slice** — beide Bedingungen sprechen über den Bestand *vor*
der Arbeit, die erste über einen **anderen** Slice. Er ist zugleich **tragend**:
[ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
Folgepflicht 1 bindet den Abschluss ihres auslösenden Slice an ihre Annahme, und dieser Slice ist
die zweite Hälfte desselben Übergabe-Artefakts (Folgepflicht 4). Er folgt ihr nach, statt ihr
vorauszulaufen.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): **Die Antwort zerfällt in eine Aussage je
  Artefaktklasse** statt in eine Regel — ein Träger-Ort für die drei Commands, ein zweiter für ein
  tool-eigenes Gefäß. Dann trägt dieser Slice den allgemeinen Teil, und die Klassen-Aussagen werden
  eigene.
- `in-progress` → `open` (blockiert — Carveout?):
  [ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) wird
  überholt, oder ihre Festlegung 2 (a) bewegt sich unter dem Lauf. Dann wäre die Antwort gegen einen
  abgelösten Stand geschrieben, und der Gegenstand wandert.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. **Beide Liefer-Punkte aus §2 tragen einen ihrer zulässigen Ausgänge**, und `make gates` meldet
   Exit 0. Der Umsetzungs-Commit nennt die neue ADR, ihre Stelle und die Rolle.
2. **Der Review-Report liegt unter `docs/reviews/` und trägt keinen blockierenden Befund.** Er
   prüft die Festlegung gegen die drei Klauseln, gegen die sie sich abgrenzt (§1) — dieselbe
   Konsistenz-Runde, die
   [ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)
   §Der Acceptance-Trigger für sich verlangt.

**Lerneintrag:** die Form entscheidet die Closure, nicht dieser Plan. Was aus
[ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) und
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) folgt, trägt bereits
eine ID und braucht keinen zweiten Anker (Baseline-Regelwerk `grundlagen-traceability.md`
§Herkunfts-Anker, Geltungsbereich); das Feld `liegt in` steht nur, wenn mit diesem Slice wirklich
eine Regel aus der 3×-Schwelle verkörpert wurde.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **(1) Die Antwort reicht weiter als ihre Quelle.** Eine Aussage über *alle* Rollen-Artefakte des
  Ziels nähme die Typkarten mit, die
  [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 3 ausnimmt
  und [ADR-0029](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) offen lässt —
  die Register-Klasse
  [`BEO-ALL/zusammenfassung-staerker-als-ihre-quelle`](../observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md),
  **8×** (`ls docs/plan/planning/observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/evidence/*.md | wc -l`,
  kein Erwartungswert). **Gegenmittel im Plan:** §1 nimmt die Typkarten namentlich aus, und
  Liefer-Punkt (1) verlangt, dass die Festlegung ihren Geltungsbereich nennt.
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>
- **(2) Die Antwort bleibt für ihre Verkörperung ohne Adresse.** Fällt sie *„Aussage"* und nennt
  den Träger-Ort nicht **mitsamt** der Rolle, beantwortet der nächste Lauf die Frage wieder
  faktisch — die Register-Klasse
  [`BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md)
  steht bei **1×** (`ls docs/plan/planning/observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/evidence/*.md | wc -l`,
  kein Erwartungswert) und wüchse um einen Beleg. **Gegenmittel im Plan:** Liefer-Punkt (1) verlangt
  bei *„Aussage"* Träger **und** Rolle; §1 nennt die Ausführung als eigenen Vorgang der Rolle, der
  die Datei gehört.
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>
- **(3) Der Quelle wird beim Ausführen die Grundlage entzogen.** Läuft die Runde erst nach einem
  weiteren Baseline-Sprung oder nach einer Überarbeitung, die Festlegung 2 (a) von
  [ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) bewegt, so
  misst die Antwort gegen einen Stand, den der Baum nicht mehr führt — die Register-Klasse
  [`BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`](../observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/observation.md),
  **6×** (`ls docs/plan/planning/observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/evidence/*.md | wc -l`,
  kein Erwartungswert). **Gegenmittel im Plan:** Der Start-Trigger aus §4 bindet den Lauf an den
  Abschluss des auslösenden Slice, und §2 Liefer-Punkt (2) schreibt die Quelle im **selben** Vorgang
  fort — der Bezug altert damit nicht über den Slice hinaus. — **Ausgang:** <eingetreten /
  entfallen / weiter offen — bei Closure zu setzen>

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
- **Beobachtungs-Register (`../observations/`):** <der Gegenstand berührt
  `BEO-ALL/anweisungssatz-eigentum-ohne-quelle` — dessen `state.md` führt die **emittierte Ebene**
  nicht als offenen Teil; ob die Antwort einen Beleg wert ist, entscheidet diese Closure, und
  angelegt wird hier, gezählt wird nicht>
- **Folge-Slices:** <fällt die Antwort *„Aussage"*, nennt Liefer-Punkt (1) Träger und Rolle; sein
  Ausführungs-Vorgang wird hier mit Kennung geführt — oder ausdrücklich nicht, mit Grund>
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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area: `*`
(gesamtes Repo, Kürzel `ALL`), deklariert in
[`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area.
Die Schwelle ≥ 2 von 3 Achsen ist erfüllt: eigener Konventions-Bestand (die Eigentums-Familie als
Norm-Achse), eigener Prüfbereich (die ADR-Ablage und ihr Index, [`make docs-check`](../../../../harness/sensors/docs-check.md))
und eigene Fehlermodi (eine Festlegung, die weiter reicht als ihre Quelle).
**`TOOLS` und `CODEX` sind geprüft und nicht berührt:** Weder `harness/tools/` noch `.codex/` trägt
eine Aussage dieses Slice; Pfad-Berührung allein genügt nicht.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist am gemergten Stand durchgegangen —
**115** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, **kein
Erwartungswert**,
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2: ein Zähler-Stand ist eine datierte Messung); alle führen dieselbe Sub-Area `*`, die
Sichtung ist damit vollständig. **Fünf Treffer** berühren diesen Slice:

| Beobachtung (`BEO-ALL/<slug>`) | Zähler | Stand | wo sie diesen Slice trifft |
|---|---|---|---|
| [`anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md) | 5× | geplant | §1 — sein `state.md` führt die **emittierte Ebene** nicht als offenen Teil; genau die nimmt dieser Slice |
| [`eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md) | 1× | offen | §1 — dieser Slice gibt der Frage einen Träger, statt sie faktisch beantworten zu lassen; §6 Risiko (2) |
| [`uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md) | 6× | verkörpert | §1 — dieser Slice **ist** das Träger-Artefakt einer Übergabe ([ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) Folgepflicht 4) |
| [`fremdes-rollen-artefakt-im-implementations-kontext`](../observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md) | 9× | verkörpert | §1 — die Abgrenzung *„kein Satz im emittierten Satz"* hält den Slice aus einem fremden Rollen-Artefakt heraus |
| [`zusammenfassung-staerker-als-ihre-quelle`](../observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md) | 8× | geplant | §6 Risiko (1) — eine Aussage über *alle* Rollen-Artefakte liefe ihrer Quelle voraus |

```sh
for s in anweisungssatz-eigentum-ohne-quelle \
         eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet \
         uebergabe-an-andere-rolle-ohne-traeger-artefakt \
         fremdes-rollen-artefakt-im-implementations-kontext \
         zusammenfassung-staerker-als-ihre-quelle; do
  printf '%s %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" "$s"
done
```

**Keiner der fünf steht bei 2×**, keiner erreicht **mit diesem Slice** die 3×-Schwelle; zwei tragen
ihren Ausgang (verkörpert), drei warten auf den Lese-Schritt der nächsten Welle-Closure. **Ein
eigener Folge-Slice entsteht aus dieser Sichtung also nicht** — die Zähler-Stände gehören ins
Kriterium *Evidenz-/Diskrepanz-Risiko* unten, den Ausgang weist der Lese-Schritt zu, nicht diese
Planung.

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas sind Greenfield; der Block trägt eine
Sub-Area.

### Sub-Area: `*` (gesamtes Repo, Kürzel `ALL`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch für die Eigentums-Frage — fünf Entscheidungen führen sie
  ([ADR-0015](../../adr/0015-rollen-eigentum-an-norm-artefakten.md),
  [ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md),
  [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
  [ADR-0048](../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md),
  [ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md)), und
  **niedrig für die Emissions-Kante**: wie eine Vorlage `skip-if-present` wird, steht in
  [ADR-0007](../../adr/0007-bootstrap-phasen.md) Festlegung 3 — was daraus für eine **Aussage**
  folgt, steht in keiner Festlegung, sondern als Begründung im Rumpf von
  [ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 5.
- **Phase-Reife:** Phase 4 für die ADR-Ablage — Ziel-Form, Index und `adr-immutable` stehen; Phase 2
  für die Frage selbst, die keine Prozedur und keinen Prüfer hat.
- **Evidenz-/Diskrepanz-Risiko:** **mittel**, und der Gegenstand ist der Grund: Der Satz, der die
  Frage heute ausnimmt, steht in **drei** Entscheidungen und wird von jeder mit einer *anderen*
  Wendung geführt (§1). Welche davon der Träger-Ort ist, macht erst die Antwort sichtbar; die
  Register-Klasse [`zusammenfassung-staerker-als-ihre-quelle`](../observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md)
  (**8×**) ist genau die Gefahr, dass die Antwort über ihre Quelle hinaus greift.
- **Reconciliation-Aufwand:** keiner — GF, kein Inventur-Fund; die Datei `reconciliation.md`
  existiert in diesem Repo nicht, und das zugehörige DoD-Item entfällt deshalb in §2. Graduation
  entfällt (n/a bei GF).

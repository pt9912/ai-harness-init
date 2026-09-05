# Slice slice-181: Eine Grenzen-Liste ist vollständig, oder der Ausdruck fällt über der Form, die sie nicht führt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD unten; ein repo-weiter Beleg darüber
hinaus steht in keinem Kriterium (Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht,
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)).

**Bezug:**
[`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md) (3×, geplant — dieser Slice ist der benannte Ausgang des
Lese-Schritts),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein Wächter, der eine Menge zusagt und eine engere prüft, ist dieselbe Klasse eine Ebene
tiefer),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (die Zusage ist erst fertig, wenn ihr Gegenbeispiel
rot gesehen wurde) und §3.7 (die Klasse *Grenze* — die Zusage auf das einschränken, was der
Code hält),
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (das Verhältnis
von schreibender Rolle und Artefakt, hier für den zweiten Liefer-Punkt tragend).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** `—` bis zur Priorisierung (Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine). **Die zwei Liefer-Punkte haben
verschiedene schreibende Rollen** — der erste liegt beim Implementer, der zweite ist eine
Schärfung der Hard Rules und damit Architect-Arbeit ([`AGENTS.md`](../../../../AGENTS.md)
§3.8). Sie gehören darum in getrennte Commits, und die Priorisierung setzt zwei
Rolleninhaber statt eines.

**Autor:** Planner. **Datum:** 2026-09-04.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Wer neben einem Ausdruck eine Grenze nennt, nennt sie vollständig — oder der Ausdruck
urteilt nicht über eine Eingabe-Form, die er nicht zerlegt.**

Der Kopplungs-Wächter `test/unterkommando-kopplung.bats` sagt zu, geprüft werde Mitgliedschaft
in der Menge der `case`-Marken **am Zeilenanfang**, „ein `case \"…\":` in einer KOMMENTAR-Zeile
dispatcht nichts", und nennt daneben **eine** Grenze (die Mehrfach-Marke, fail-closed). Das
Muster `^[[:space:]]*case "[^"]*":` trennt aber nur die `//`-Form ab; eine Zeile **innerhalb**
eines `/* … */`-Blocks trägt vor `case` nur Leerraum und fällt in die Menge herein. Der Wächter
bleibt damit grün, während der Bedien-Einstieg gebrochen ist. Dieselbe Zusage steht in
[`harness/README.md`](../../../../harness/README.md).

Das ist die **dritte** Instanz von [`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md), und mit ihr die Schwelle:
eine Zusage nennt einen Geltungsbereich, den der Ausdruck darunter nicht hält.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Der Kopplungs-Wächter urteilt nicht über eine Datei, deren Form er nicht zerlegt** —
      entweder trennt der Ausdruck die Block-Kommentarform ab, oder er bricht fail-closed ab,
      sobald die geprüfte Datei eine Form trägt, die er nicht führt. **Rot zu sehen:** den Zweig
      des Dispatch umbenennen und die alte Marke in einen `/* … */`-Block derselben Datei setzen
      — heute bleibt `make test-bats` darüber grün, gemessen an
      [slice-175](../done/slice-175-archive-welle-schreibender-pfad.md) §7. Der Fall gehört als
      eigener Zahn nach `test/mutations/`. Im selben Zug nennt die Zusage in
      `test/unterkommando-kopplung.bats` und in
      [`harness/README.md`](../../../../harness/README.md) genau die Grenzen, die der Ausdruck
      hält — nicht mehr und nicht weniger.
- [ ] **Die Klasse bekommt ihre Regel** — eine Grenzen-Liste neben einem Ausdruck ist
      vollständig, oder der Ausdruck fällt über der nicht geführten Form fail-closed. Zielort ist
      [`AGENTS.md`](../../../../AGENTS.md) §3.6 oder §3.7; das ist eine **Verschärfung** und
      braucht darum kein ADR (§3.5 bindet Senkungen). Geschrieben wird sie vom **Architect**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.8), in einem eigenen Commit, der nur
      Architect-Artefakte berührt. Trägt die Prüfung stattdessen zu einer **Ablehnung** — die
      Regel ist nicht formulierbar, ohne mehr zu verbieten als die Klasse —, ist die begründete
      Ablehnung der Liefer-Punkt und wandert als Stand in die Registerzeile.
- [ ] `make gates` grün.
- [ ] Doku-Update: [`harness/README.md`](../../../../harness/README.md), soweit die Zusage über
      den Kopplungs-Wächter dort mitwandert (Liefer-Punkt 1).
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
| `test/unterkommando-kopplung.bats` | update | der Ausdruck trennt die zweite Kommentarform ab oder bricht über ihr ab; die Zusage daneben nennt die Grenzen, die er hält |
| `test/mutations/` | neu | ein Zahn für genau diese Form — die Sonde `S8` als gelisteter Fall |
| [`harness/README.md`](../../../../harness/README.md) | update | dieselbe Zusage steht dort; eine Aussage hat einen Ort, aber zwei Fassungen derselben driften |
| [`AGENTS.md`](../../../../AGENTS.md) §3.6/§3.7 | update | Liefer-Punkt 2 — **Architect**, eigener Commit |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-175](../done/slice-175-archive-welle-schreibender-pfad.md) liegt in `done/` — dessen
Lese-Schritt weist [`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md) diesen Slice als Ausgang zu, und vorher gibt
es weder die dritte Instanz noch die Zuweisung.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Regel aus Liefer-Punkt 2
  nicht ohne eine eigene Abzählung der betroffenen Ausdrücke formulierbar ist — dann geht die
  Regel als eigener Architect-Slice zurück und der gemessene Fall bleibt hier.
- `in-progress` → `open` (blockiert — Carveout?): wenn die fail-closed-Variante von
  Liefer-Punkt 1 den Wächter über dem heutigen `cmd/ai-harness-init/main.go` rot färbt —
  dann steht die Form der Quelldatei zur Entscheidung, nicht der Wächter.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; die Sonde `S8` ist als Fall unter `test/mutations/` gelistet und einmal rot
gesehen, während der unmutierte Baum grün bleibt; `make gates` grün; Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Ein Ausdruck, der Go-Quelltext in einer Shell-Prüfung zerlegt, ist selbst eine
  Grenzen-Liste.** Wer die Block-Kommentarform abtrennt, hat den nächsten Fall (ein
  Zeichenketten-Literal, das die Marke enthält) noch vor sich; die fail-closed-Variante
  vermeidet das, kostet aber eine Sperre über einer Datei, die niemand ändern wollte. Welche der
  zwei Varianten trägt, ist im Slice zu entscheiden und nicht vorab. — **Ausgang:** <eingetreten:
  CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im Register>
- **Liefer-Punkt 2 kann in eine Regel laufen, die mehr verbietet als die Klasse.** Eine
  Grenzen-Liste ist in fast jedem Kommentar dieses Repos unvollständig, wenn man den Maßstab
  streng genug legt; eine Regel ohne Cutoff wäre dauerhaft rot und entwertete sich selbst —
  dieselbe Erwägung, die [`AGENTS.md`](../../../../AGENTS.md) §3.7 ihren Cutoff gibt. —
  **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im
  Register>
- **Der Restschaden des heutigen Standes ist ungleich verteilt, und die schwächere Hälfte hat
  keinen Wächter.** Für `archive-welle` fängt `make test-go` denselben mutierten Baum auf — drei
  `--- FAIL:` in `cmd/ai-harness-init/archive_welle_echt_test.go`, das den Träger als Prozess
  durch den echten Dispatch fährt; für `span-report` steht daneben nichts in `make gates`
  (gemessen in [slice-175](../done/slice-175-archive-welle-schreibender-pfad.md) §7). Wer
  Liefer-Punkt 1 auf die
  Zusagen-Hälfte verkürzt, lässt genau diese Hälfte offen. — **Ausgang:** <eingetreten: CO-NNN /
  slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im Register>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — `test/` und
[`AGENTS.md`](../../../../AGENTS.md) liegen in keiner engeren Sub-Area der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area).

**Vorgelagert — offene Beobachtungen sichten:** Drei Treffer im [Register](../observations/README.md),
je mit dem Stand, den das Register führt (für jeden Slug die Zahl der `evidence/`-Dateien und die
erste Zeile seiner `state.md`:
`for s in zusage-neben-geaenderter-ableitung-bleibt-stehen schwellen-uebertritt-ohne-zustaendige-rolle zusage-nennt-sensor-der-form-nicht-sieht; do d="docs/plan/planning/observations/BEO-ALL/$s"; echo "$s $(ls "$d/evidence" | wc -l)x $(head -1 "$d/state.md")"; done`;
keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). `BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht` ist der **Gegenstand** dieses Slice und steht darum nicht zusätzlich als
Risiko in §6. `BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen` ist berührt, aber nicht getroffen: Liefer-Punkt 1 zieht die Zusage im
selben Zug wie den Ausdruck nach — genau der Fall, den jene Klasse offen lässt. `BEO-ALL/schwellen-uebertritt-ohne-zustaendige-rolle` ist
berührt, weil Liefer-Punkt 2 in einer anderen Rolle liegt als der Slice-Schnitt; er tritt hier
**nicht** ein, denn der Ausgang ist als Kennung zugewiesen und nicht vertagt. Weitere Treffer:
keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.

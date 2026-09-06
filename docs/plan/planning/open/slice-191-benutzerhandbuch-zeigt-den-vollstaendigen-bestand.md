# Slice slice-191: Das Benutzerhandbuch zeigt den Bestand, den der Bootstrap wirklich anlegt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Die Closure-Bedingung wäre die Abschrift der DoD unten
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).
Damit **nicht** in der Roadmap geführt.

**Ebene: Dogfood-Doku über die emittierte Ebene.** Gegenstand ist
[`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md) §6 —
eine Datei **dieses** Repos, die über den Bestand eines **fremden** Ziels
spricht. Der Generator selbst ist nicht berührt.

**Bezug:** [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
(der emittierte Bestand, über den §6 spricht),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(die Gegenkraft, falls dieser Slice einen Wächter setzt: kein Gate über leerem
Prüfbereich),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(eine Zahl im Text steht neben dem Kommando, das sie liefert — die Regel, aus der
die Form der Lösung folgt),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-*Anheben* ist ein Steering-Loop, kein ADR),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes
Gegenbeispiel).

**Berührte Spec-Stellen:** `ARC-003` (Idempotente Ablage,
[`spec/architecture.md §1`](../../../../spec/architecture.md#1-komponenten-übersicht))
· Technik: `—`.

**Verantwortlich:** — (bis zur Priorisierung).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-09-06.

---

## 1. Ziel

**Wer das Handbuch liest, sieht, was der Bootstrap wirklich anlegt — und wer
etwas hinzufügt oder vergisst, sieht es am Handbuch, nicht erst an einem
fremden Repo.**

§6 *Was wird angelegt* zeigt heute einen zusammenfassenden Baum. Er nennt
**zwölf** Einträge:

```sh
sed -n '/^mein-projekt\/$/,/^```$/p' docs/user/benutzerhandbuch.md \
  | grep -cE '^[│├└ ]'                                              # 12
```

Der reale Bestand eines dokument-only gebootstrappten Ziels ist um eine
Größenordnung größer — gemessen an einem frischen Lauf
(`ai-harness-init --name smoke` in ein leeres `git`-Repo):

```sh
find . -path ./.git -prune -o -path ./.harness/baseline -prune -o -type f -print | wc -l   # 44
find . -path ./.git -prune -o -path ./.harness/baseline -prune -o -type d -print | wc -l   # 24
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide Zahlen wandern mit dem Generator. Genau das ist der Punkt.

**Die Verkürzung ist nicht Bequemlichkeit, sie ist der Grund, warum eine Lücke
lange unbemerkt blieb.** Der Baum fasst `docs/plan/` zu **einer** Zeile zusammen
und beschreibt ihren Inhalt als *„Architektur-Entscheidungen, Slices, Roadmap,
Beobachtungs-Register"*. Das Beobachtungs-Register entsteht dort nicht — die
Zeile behauptet einen Ort, den kein Emissions-Pfad anlegt, und weil sie kein
Verzeichnis einzeln nennt, fällt das beim Lesen nicht auf. Dasselbe gilt für
`harness/conventions/` und `docs/plan/carveouts/done/`, die
[slice-190](slice-190-bootstrap-legt-die-versprochenen-orte-an.md) nachträgt.

**Zwei Dinge sind zu liefern, und sie hängen zusammen.** Erst muss entschieden
sein, *was* der Baum zeigt — ohne diese Entscheidung gibt es nichts, was ein
Wächter halten könnte; dann muss er gegen den realen Bestand gehalten werden,
sonst ist er in drei Slices wieder alt. Ein Baum, den ein Mensch pflegt, ist
eine zweite Fassung derselben Aussage, und Kopien driften.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) §6 zeigt den vollständigen Bestand, für beide Phasen.**
  `docs/user/benutzerhandbuch.md` §6 nennt für den dokument-only-Bootstrap
  **jede** Datei und **jedes** Verzeichnis einzeln, das der Lauf real anlegt, und
  für den Sprachmodul-Bootstrap das Delta dazu. **Die Ausnahme ist zu benennen,
  nicht stillschweigend zu machen:** `.harness/baseline/` trägt allein
  `find . -path ./.git -prune -o -type f -print | wc -l` **98** gegen **44** ohne
  ihn — der vendored Baum ist ein Fremd-Blob, seine Datei-für-Datei-Auflistung
  wäre kein Bestandsbild, sondern ein Inhaltsverzeichnis des Kurses. Er steht als
  **ein** Eintrag mit seiner Zahl daneben.
- [ ] **(2) Der Baum ist gegen den realen Bestand gehalten, nicht von Hand
  gepflegt.** Ein Wächter vergleicht die im Handbuch genannten Pfade mit der
  Menge, die der Emitter liefert — die dieselbe Quelle ist, die
  `TestTemplates_EmittierterBestandVollstaendig` schon als `want`-Liste führt.
  **In beide Richtungen**, wie bei der Bijektion in Modul 6: ein genannter Pfad
  ohne Emission und ein emittierter Pfad ohne Nennung sind derselbe Defekt.
  **Rot-Nachweis:** ein Eintrag wird aus `structureGitkeeps()` genommen, ohne das
  Handbuch anzufassen — der Wächter muss rot werden; und ein Pfad wird im
  Handbuch erfunden — er muss ebenfalls rot werden. Beide Richtungen einmal rot
  gesehen, sonst ist der Wächter eine Behauptung
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Ein `test/mutations/`-Fall hält den
  Zahn.
- [ ] **(3) Die Aussage über den Register-Ort ist mit dem Bestand in
  Übereinstimmung.** Die `docs/plan/`-Zeile nennt heute das
  Beobachtungs-Register als Inhalt; ob der Ort entsteht, entscheidet das Risiko
  aus [slice-190](slice-190-bootstrap-legt-die-versprochenen-orte-an.md) §6.
  **Dieser Slice erfindet die Entscheidung nicht** — er schreibt den Baum so,
  wie der Bestand zum Zeitpunkt der Umsetzung ist, und der Wächter aus (2) hält
  ihn danach unabhängig davon, wie sie ausfällt.
- [ ] `make gates` grün; `make full-smoke` grün; `make mutate` grün über die CI.
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
| [`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md) §6 | update | DoD (1) und (3) — der vollständige Baum für beide Phasen |
| ein Wächter über der Pfad-Menge (Ort offen: Go-Test neben `templates_test.go` oder bats-Fall) | neu | DoD (2); der Ort folgt aus der Frage, welche Quelle die Menge liefert, und die steht in Go |
| `test/mutations/` | neu | der kuratierte Fall zum Wächter aus DoD (2) |
| `internal/emit/` | **unverändert** | der Generator ist nicht Gegenstand; wer hier etwas ändert, ist in [slice-190](slice-190-bootstrap-legt-die-versprochenen-orte-an.md) |
| [`harness/README.md`](../../../../harness/README.md) §Sensors | update **falls** der Wächter ein `make`-Ziel bekommt | ein genanntes Ziel muss existieren ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)); hängt er in `make test`, entfällt der Eintrag |

**Was die Umsetzung zuerst entscheidet** (Modul 9 §4): **welche Quelle die
Soll-Menge liefert.** Drei Kandidaten, und sie sind nicht gleichwertig — die
`want`-Liste in `internal/emit/templates_test.go` (heute schon der
Mengen-Vergleich, aber eine Test-Konstante), `emit.Templates()` selbst über einen
Temp-Baum (die Wahrheit, aber im Test teurer), oder ein echter Bootstrap-Lauf
(am nächsten am Nutzer, braucht Docker und fällt damit aus `make test` heraus).
Die Wahl bestimmt, wo der Wächter läuft, und gehört in den ersten Lauf — nicht
in diesen Plan, der sie sonst ohne Messung vorwegnähme.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**`open` → `next`:** [slice-190](slice-190-bootstrap-legt-die-versprochenen-orte-an.md)
liegt in `done/`. **Kein Zwang, sondern Ökonomie:** slice-190 bewegt die
Soll-Menge, und ein Baum, der davor geschrieben wird, ist beim Merge von
slice-190 wieder alt. Läuft dieser Slice zuerst, färbt sein eigener Wächter aus
DoD (2) den Nachbarn rot — was funktioniert, aber die Arbeit zweimal macht.

**Start** (`next` → `in-progress`): Implementer übernimmt, WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): falls sich zeigt, dass
  der Wächter aus DoD (2) eine **dritte** Bestands-Quelle braucht, die es noch
  nicht gibt (etwa einen Bootstrap-Lauf außerhalb von `make test`). Dann trennt
  ein Re-Schnitt den vollständigen Baum von seinem Wächter — der Baum allein hat
  Liefer-Wert, der Wächter ohne ihn nicht.
- `in-progress` → `open` (blockiert — Carveout?): falls der vollständige Baum in
  §6 als Lesehilfe unbrauchbar wird — 44 Zeilen statt 12 sind ein
  Benutzerhandbuch, kein `find`-Protokoll. Dann ist erst zu klären, wie
  Vollständigkeit und Lesbarkeit zusammengehen (zwei Bäume? ein Anhang?), bevor
  geschrieben wird.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **(a)** beide Rot-Nachweise aus DoD (2) sind
gefahren und ihre Ausgabe gelesen — der weggenommene Emissions-Eintrag **und**
der erfundene Handbuch-Pfad, je mit der Meldung, die der Wächter dabei ausgibt;
**(b)** `make gates` und `make full-smoke` grün, `make mutate` grün über die CI.

Dazu: DoD vollständig; Review konform (Modul 10); Verifikation bestätigt
(Modul 11); jedes Risiko aus §6 mit Ausgang; Closure-Notiz mit
Steering-Loop-Lerneintrag; `git mv` nach `done/` als eigener Move-Commit. Den
Abschluss schreibt der **Planner** in frischem Kontext
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Vollständigkeit und Lesbarkeit ziehen gegeneinander.** Ein
  Benutzerhandbuch ist zum Lesen da; ein Baum mit **44** Dateien ist eine
  Bestandsliste. Wird der Baum unbenutzbar, ist die Rückführung nach `open` der
  richtige Zug (§4) und nicht die stille Kürzung — die wäre der Zustand, aus dem
  dieser Slice kommt. — **Ausgang:** <offen>
- **Der Wächter kann die falsche Ebene messen.** Prüft er die *Zahl* der
  Einträge statt der *Menge*, ist er grün, sobald ein Pfad gegen einen anderen
  getauscht wird — dieselbe Klasse, die
  [`BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene`](../observations/BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene/observation.md)
  führt. DoD (2) verlangt darum den Mengen-Vergleich in beide Richtungen und
  nicht einen Zähler. — **Ausgang:** <offen>
- **`.harness/baseline/` bleibt aggregiert, und das ist eine bewusste Lücke.**
  Der vendored Baum steht als **ein** Eintrag mit seiner Datei-Zahl. Wächst er
  bei einem Baseline-Sprung, bleibt der Handbuch-Baum formal richtig, ohne die
  Änderung zu zeigen. Der Ausgang wäre ein zweiter Wächter über der Zahl; er ist
  hier **nicht** gebaut, und die Lücke steht benannt statt behauptet. —
  **Ausgang:** <offen>
- **Die Register-Zeile hängt an einer fremden Entscheidung.** DoD (3) schreibt
  den Bestand zum Zeitpunkt der Umsetzung; fällt die Entscheidung aus
  [slice-190](slice-190-bootstrap-legt-die-versprochenen-orte-an.md) §6 **nach**
  diesem Slice, ändert sich der Baum noch einmal. Der Wächter aus DoD (2) fängt
  das — er wird dann rot, und das ist der gewollte Ausgang, nicht ein Fehler
  dieses Slice. — **Ausgang:** <offen>
- **Nicht in diesem Slice:** der Generator selbst
  ([slice-190](slice-190-bootstrap-legt-die-versprochenen-orte-an.md)), die
  emittierte Modul-Liste
  ([slice-073](slice-073-emittierte-doc-gate-module.md)), und jede Aussage über
  den Bestand außerhalb von §6 des Handbuchs.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) —
[`docs/user/`](../../../../docs/user) und [`test/`](../../../../test) liegen
darunter. `harness/tools/` und `.codex/` sind **nicht** berührt; der Wächter aus
DoD (2) läuft dort nicht, und wenn die Umsetzung ihn dorthin legt, ist die
Sub-Area-Wahl neu zu stellen.

**Vorgelagert — offene Beobachtungen sichten:** Die Ablage
[`observations/`](../observations/README.md) ist durchgegangen; je Slug die Zahl
der `evidence/`-Dateien und die erste Zeile seiner `state.md`:

```sh
for s in zusage-neben-geaenderter-ableitung-bleibt-stehen \
         vollstaendigkeits-zusage-misst-falsche-ebene \
         emittierte-vorlagen-klassifikation-ohne-traeger \
         zusage-nennt-sensor-der-form-nicht-sieht; do
  d="docs/plan/planning/observations/BEO-ALL/$s"
  echo "$s $(ls "$d/evidence" | wc -l)x $(head -1 "$d/state.md")"
done
```

Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die vier Einträge des Kommandos berühren diesen Slice, weitere
Treffer: keine.

- [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  — **der Gegenstand dieses Slice.** Der `state.md` des Eintrags nennt genau
  diese Unterklasse als das, was offen bleibt: *„jede Unterklasse, in der die
  Zusage kein Anker ist … dort ist der Ausgang eine Regel ohne Sensor"*. DoD (2)
  ist der Sensor für **eine** dieser Unterklassen — die Bestands-Beschreibung —,
  nicht für alle. Was er nicht deckt, bleibt am Eintrag.
- [`vollstaendigkeits-zusage-misst-falsche-ebene`](../observations/BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene/observation.md)
  — **getroffen**: ein Wächter über einer *Zahl* statt einer *Menge* wäre genau
  ihr Fall. Steht als Risiko in §6 und ist der Grund, warum DoD (2) den
  Mengen-Vergleich in beide Richtungen verlangt.
- [`emittierte-vorlagen-klassifikation-ohne-traeger`](../observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/observation.md)
  — berührt, **nicht getroffen**: dieser Slice klassifiziert keine Vorlage. Er
  macht die Folgen einer Klassifikation nur sichtbar, was der Eintrag als
  fehlenden Träger führt.
- [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  — berührt, weil DoD (2) einen Sensor zusagt. **Nicht getroffen**, solange die
  zwei Rot-Nachweise aus §5 (a) gefahren sind: ein Sensor, der beide Richtungen
  rot gesehen hat, sieht die Form.

**Alle berührten Sub-Areas GF.** Der Modus-Begründungsblock entfällt damit
(§Umfang oben); `*` steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
als Greenfield, und dieser Slice führt keine neue Sub-Area ein.

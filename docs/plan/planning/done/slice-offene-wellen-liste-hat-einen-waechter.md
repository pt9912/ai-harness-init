# Slice slice-offene-wellen-liste-hat-einen-waechter: Die Zeiger unter „Offene Wellen" und die flachen Welle-Dateien bekommen ihren Wächter

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die mehr beobachtet als die DoD unten:
Der Gegenstand ist **eine** Fähigkeit **eines** bereits aktiven Moduls, und ihr Beleg ist der
`docs-check`-Lauf, der ohnehin in jeder DoD steht (Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht). Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap — auch nicht beim Abschluss. **Dass der Gegenstand
eine neue Fähigkeit ist, macht ihn nicht zur Welle**; genau diese Frage hat jener Eintrag
zugunsten der Baseline entschieden.

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist ausschließlich die
[`.d-check.yml`](../../../../.d-check.yml) **dieses** Repos. Die Doc-Gate-Startkonfiguration, die
das Werkzeug in ein Zielrepo schreibt, bleibt unberührt (§1) — die zwei Ebenen tragen verschiedene
Verträge und verschiedene Gründe.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Gate sagt, was es prüft; eine unbewachte Hälfte wird benannt statt verschwiegen),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Trockenlauf fährt
gegen den gepinnten Digest, netzlos),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-*Anheben* läuft über den Steering-Loop, nicht über eine ADR — §1),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando),
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
(die Zähler-Stände in §8 sind datierte Messungen),
[ADR-0044](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) (§Konsequenzen trägt die
Auftraggeber-Vorgabe, die der Anlass dieses Slice ist).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand sind eine
Gate-Konfiguration und ihre Sensor-Prosa).

**Verantwortlich:** Implementer-Rolleninhaber dieses Laufs.

**Autor:** Planner. **Datum:** 2026-09-13.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Die **Listen-Hälfte** des Abschnitts *Offene Wellen* — die Bijektion zwischen den
Zeigern dort und den flachen Welle-Dateien — wird von der `waves`-Fähigkeit des bereits aktiven
Moduls `planning` gehalten, und ihre eine Richtung ist einmal rot gesehen.

### Die Lücke ist heute benannt, nicht gedeckt

[`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) §Modul `planning`
führt sie als ausdrückliche Grenze: Die Marker-Hälfte hält `heading`/`marker`, die Listen-Hälfte
*„bleibt unbewacht"*. Derselbe Text steht als Begründungs-Kommentar über dem `planning:`-Block der
[`.d-check.yml`](../../../../.d-check.yml).

```sh
grep -c 'waves' .d-check.yml                       # 1 — genau der Kommentar, der das Ausbleiben begruendet
grep -n 'waves' harness/sensors/docs-check.md      # 22, 25, 26, 33 — die Prosa-Haelfte derselben Aussage
grep -m1 '^modules:' .d-check.yml | tr ',' '\n' | wc -l   # 8 — planning ist aktiv, waves ist eine Faehigkeit davon
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — alle drei wandern mit dem Stand.

### Der Anlass, und warum er nicht in diesem Slice abgewogen wird

Das Ausbleiben trägt **eine** Abweichung als Grund: *dieses Repo schneidet die Welle-Datei, bevor
der Start-Trigger eintritt*. **Diese Abweichung ist heute nirgends gesetzt** — der Adaptions-Block
führt keinen Eintrag dazu
(`git grep -l 'waves' -- harness/conventions harness/conventions.md` gibt nichts aus), und in der
Roadmap steht sie ebenfalls nicht mehr
(`grep -c 'waves' docs/plan/planning/in-progress/roadmap.md` → **0**; der Ortswechsel hängt an
`1be6be03`). Sie neu zu setzen, schließt eine Vorgabe des Auftraggebers aus, verbucht in
[ADR-0044](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen: *„Der
Adaptions-Durchgang übernimmt die Ziel-Fassung vollständig; eine Abweichung wird nicht gesetzt."*
**Die Vorgabe bindet wörtlich den Adaptions-Durchgang, nicht diesen Slice** — sie ist sein Anlass,
nicht seine Anweisung, und das ist der Grund, warum die Frage unten beim Architect liegt statt
hier beantwortet zu werden.

**Ob die Abweichungs-Frage mit der Aktivierung entfällt oder vorher einen Eintrag braucht,
entscheidet dieser Slice nicht** — der Adaptions-Block ist Architect-Eigentum
([`AGENTS.md`](../../../../AGENTS.md) §3.8). Die Frage steht als Übergabe in §6 und als
Rückführungs-Bedingung in §4.

### Der Weg ist Steering-Loop, nicht ADR

Eine Aktivierung **hebt** den Gate an.
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
§Begründung setzt dafür *„Gate-*Anheben* → Steering-Loop, kein ADR nötig"*; die ADR-Pflicht aus
[`AGENTS.md`](../../../../AGENTS.md) §3.5 greift nur bei **Senkungen**. Konkret heißt das drei
Dinge und nicht mehr: eigener Trockenlauf gegen den gepinnten Digest, eigene Config-Entscheidung,
und ein Lerneintrag in der Form *neuer Sensor* bei der Closure (§5, §7). Dieselbe Lesart trägt
`state.md` von
[`BEO-ALL/register-paarung-ohne-gate-modul`](../observations/BEO-ALL/register-paarung-ohne-gate-modul/observation.md)
für die Schwester-Fähigkeit `observations`.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Aktivierung von `planning.observations`** — der vierten Fähigkeit desselben Moduls. Sie
  hat ihre eigene Config-Entscheidung (`dirs` und `pattern` treffen dieses Repo vorgabegemäß
  beide nicht) und ihre eigene, schmaler als der Bestand liegende Deckung; sie mit hereinzunehmen
  ergäbe zwei Trockenläufe und zwei rote Gegenbeispiele in einem Slice. *Es wäre ein anderer
  Vorgang.*
- **Keine Änderung an der emittierten Doc-Gate-Vorlage**
  [`internal/emit/templates/d-check.yml`](../../../../internal/emit/templates/d-check.yml). Was
  in die Startkonfiguration eines Zielrepos geht, entscheiden die eigenen Kriterien von
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  — Erprobung im Dogfood, grün über dem frisch emittierten Bestand, rotes Gegenbeispiel im Ziel —,
  und die **erste** davon ist genau das, was dieser Slice liefert. *Es wäre ein anderer Vorgang.*
  **Eine Folge-Slice-Kennung steht hier nicht:**
  [slice-210](../open/slice-210-planning-modul-im-emittierten-doc-gate.md) entscheidet über die
  emittierte Modul-Aktivierung und **schließt `waves` in seinem eigenen §1 aus** — er nimmt die
  Sendung nicht an, und eine Adresse, die sie nicht annimmt, ist keine.
- **Keine Änderung an `modules:` und darum keine an den Gate-Tabellen.** `waves` ist eine
  **Fähigkeit** von `planning`, kein Modul; die Liste bleibt bei acht
  (`grep -m1 '^modules:' .d-check.yml | tr ',' '\n' | wc -l` → **8**). Damit ändert sich keine
  `make X`-Zeile in [`AGENTS.md`](../../../../AGENTS.md) §4 oder
  [`harness/README.md`](../../../../harness/README.md), und das Modul `targets` bleibt unberührt.
  *Bestand bleibt bewusst stehen.*
- **Kein Nachzug der drei übrigen `harness/README.md`-Zeiger im `planning:`-Kommentar.** Der Block
  verweist viermal auf eine Datei, die den Text nicht mehr trägt; dieser Slice zieht **einen**
  davon nach — den, den er ohnehin neu schreibt. Die Fundmenge ist gemessen, nicht geschätzt:
  `grep -c 'harness/README.md' .d-check.yml` → **9**, davon in den Zeilen 39–49 des
  `planning`-Kommentars **4** (`sed -n '30,50p' .d-check.yml | grep -c 'harness/README.md'`),
  und `grep -c 'waves' harness/README.md` → **0**,
  `grep -c 'closure' harness/README.md` → **0**. Die drei übrigen gehören zur `closure`-Fähigkeit,
  deren Prosa ein eigener Absatz derselben Sensor-Datei trägt. *Es wäre ein anderer Vorgang* —
  und die Messung steht hier, weil ein Befund über eine Aussage ihre **Fundmenge** nennt und nicht
  nur den Fundort.
- **Kein Produkt-Code.** Der Slice ändert eine Gate-Konfiguration und Doku; `internal/`, `cmd/`
  und `harness/tools/` bleiben unberührt. *Schicht-Abgrenzung* — beim Review sofort prüfbar.

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

**Drei Liefer-Punkte, und der zweite ist das Rot:**

- [x] **(1) Die Fähigkeit ist verdrahtet und der Bestand bleibt grün.**
      [`.d-check.yml`](../../../../.d-check.yml) trägt unter `planning:` einen `waves:`-Block mit
      `dir` **und** `mode: many`; `make docs-check` meldet über dem unveränderten Bestand
      `0 Befund(e)`, Exit 0. Der Kommentar über dem Block beschreibt, **was die Fähigkeit prüft**,
      statt zu begründen, warum sie ausbleibt, und sein Begründungs-Zeiger nennt den lebenden
      Träger [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) statt
      `harness/README.md`.
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6))
- [x] **(2) Richtung A ist einmal rot gesehen** — eine flache Welle-Datei ohne Zeiger unter
      *Offene Wellen* färbt den Lauf rot. Der Umsetzungs-Commit trägt das Kommando, das es rot
      färbt, den Grund-Code und die Ausgabe; gefahren gegen eine Kopie **außerhalb** des Repos
      (`git archive HEAD | tar -x`), netzlos (`--network none`), Mount `:ro`, mit dem Digest aus
      [`d-check.mk`](../../../../d-check.mk). **Ohne dieses Rot wird nicht verdrahtet** —
      [`AGENTS.md`](../../../../AGENTS.md) §3.6.
      ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit))
- [x] **(3) Die Sensor-Prosa beschreibt die Deckung statt ihres Ausbleibens.**
      [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) §Modul
      `planning` sagt, was `waves` hält — **beide** Richtungen der Bijektion unter *Offene Wellen*,
      Datei ohne Zeiger **und** Zeiger ohne Datei, unter dem Grund-Code `wave-drift` — **und nennt
      die Grenze**: Ein toter Zeiger in der **Vorschau**-Tabelle *Nächste Wellen* fällt
      ausschließlich über das Modul `links` (`target-missing`), nicht über `waves`. Die Zusage
      nennt damit genau die Kante, die das Modul trägt, und keine zweite.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: Liefer-Punkt (3) **ist** dieses Item — der Gate-Vertrag ist ein öffentlicher
      Vertrag, und seine Prosa liegt in
      [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag in der Form **neuer Sensor** — der Weg, den
      [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
      §Begründung für ein Gate-*Anheben* vorsieht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — **hier nicht**: Dieses
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
| [`.d-check.yml`](../../../../.d-check.yml), `planning:`-Block | update | trägt den `waves:`-Block mit `dir` und `mode: many` — Liefer-Punkt (1) |
| [`.d-check.yml`](../../../../.d-check.yml), Kommentar über `planning:` | update | beschreibt, was die Fähigkeit prüft, statt warum sie ausbleibt; Begründungs-Zeiger auf den lebenden Träger — Liefer-Punkt (1) |
| [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) §Modul `planning` | update | Deckung und Grenze statt Ausbleibe-Begründung — Liefer-Punkt (3) |

**Kein Test-Eintrag, und das ist kein Vergessen.** Der Prüfgegenstand ist eine
Gate-Konfiguration; ihr Wächter ist der Gate-Lauf selbst, und ihr Gegenbeispiel ist der
Trockenlauf aus Liefer-Punkt (2). Ein `*_test.go` oder `*.bats` daneben hielte die Konfiguration
gegen eine zweite Fassung ihrer selbst. Ob der Fall-Satz unter
[`test/mutations/`](../../../../test/mutations) einen Eintrag bekommt, entscheidet der
Umsetzungs-Lauf gegen [`make mutate`](../../../../harness/sensors/mutate.md) — dort ist die Frage,
ob ein **gelisteter** Wächter seine Zähne behält, nicht ob ein neuer entsteht.

**Reihenfolge, und sie ist nicht beliebig:**

- **Erst der Trockenlauf, dann die Config.** Die Entscheidung fällt gegen den gemessenen
  Befundstrom, nicht umgekehrt — dasselbe Muster, das
  [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  für jede Schärfung dieses Gates trägt und das
  [slice-125](../done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) für die Marker-Hälfte
  desselben Blocks gefahren hat.
- **Der Trockenlauf fährt drei Lagen:** den unveränderten Bestand, Richtung A und Richtung B — und
  er fährt sie **mit gesetztem `dir`** (§6, Risiko 1). Alle Zahlen dieses Plans sind an ihrem Stand
  gemessen und keine Erwartungswerte; der erste Schritt der Umsetzung ist, sie neu zu fahren.
- **Nicht gleichzeitig mit einem Lauf, der denselben Schlüsselbaum konfiguriert.** `planning:`
  trägt heute `heading`, `marker` und `closure`; zwei Läufe darin erzeugen einen Konflikt, den
  kein Gate meldet — die Lehre aus
  [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) §4, wo
  [slice-125](../done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) und
  [slice-129](../done/slice-129-closure-notiz-hat-einen-sensor.md) aus genau diesem Grund nicht
  parallel laufen durften.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **`in-progress/` trägt keinen Slice**, und keiner der
gleichzeitig laufenden Vorgänge konfiguriert den `planning:`-Schlüsselbaum der
[`.d-check.yml`](../../../../.d-check.yml). Beobachtbar ohne Rückfrage, in zwei Kommandos auf dem
**Hauptzweig**:

```sh
ls docs/plan/planning/in-progress/ | grep -c '^slice-'            # 0  (WIP frei; Exit 1 bei 0)
grep -rl 'planning:' docs/plan/planning/in-progress/ | grep -c .  # 0  (kein Lauf im selben Block)
```

Beide sind **heute** erfüllt (`in-progress/` trägt nur `roadmap.md`); der Trigger steht trotzdem,
weil er vor dem `git mv` erneut gelesen wird und das WIP-Limit pro Rolleninhaber **1** ist.

**Der Trigger ist kein Ergebnis dieses Slice** — er spricht über den Bestand von `in-progress/`
vor der Arbeit, nicht über die DoD unten. Die Vorgabe aus
[ADR-0044](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen steht **nicht**
im Start-Trigger: Sie ist der Anlass (§1) und bereits eingetreten; ein Trigger, der eine schon
wahre Bedingung nennt, ordnet nichts.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): **Der Trockenlauf über dem unveränderten
  Bestand meldet Befunde.** Dann liefert dieser Slice nicht eine Aktivierung, sondern zusätzlich
  eine **Form-Änderung** an der Roadmap oder an der Ablage der Welle-Dateien — ein vierter
  Liefer-Punkt und eine zweite Schicht. Zurück zum Schneiden: Form zuerst, Aktivierung danach.
  Dasselbe gilt, wenn `waves` neben `dir` und `mode` weitere Schlüssel verlangt, deren Belegung
  eine eigene Entscheidung ist.
- `in-progress` → `open` (blockiert — Carveout?): **Die Abweichungs-Frage wird vom Architect mit
  *„braucht vorher einen Eintrag"* beantwortet** (§6, Risiko 3). Der Adaptions-Block ist
  Architect-Eigentum ([`AGENTS.md`](../../../../AGENTS.md) §3.8); der Slice wartet auf den Eintrag,
  statt ihn sich selbst zu schreiben. Zweiter Fall: Ein anderer Lauf nimmt den `planning:`-Block
  in Arbeit, während dieser Slice offen ist — dann ist die Blockade die Parallelität, nicht die
  Sache.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. **`grep -A3 '^planning:' .d-check.yml` führt einen `waves:`-Block mit `dir` und `mode: many`,
   und `make gates` meldet Exit 0** — die Verdrahtung ist da und der Bestand hält sie.
2. **Der Umsetzungs-Commit trägt das Kommando, das Richtung A rot färbt, samt Grund-Code und
   Ausgabe.** Nachlesbar in `git show`; ohne dieses Rot wäre die Zusage hergeleitet statt gesehen
   ([`AGENTS.md`](../../../../AGENTS.md) §3.6).

**Lerneintrag:** in der Form **neuer Sensor** — die Listen-Hälfte des Abschnitts *Offene Wellen*
hat einen Wächter, und die Prosa sagt, welche ihrer zwei Richtungen er trägt. Das ist der Weg, den
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
§Begründung einem Gate-*Anheben* zuweist; eine ADR entsteht dafür nicht.

**Ob der Eintrag daneben ein `liegt in`-Feld trägt, entscheidet die Closure und nicht dieser
Plan.** Das Feld steht nur, wenn mit diesem Slice wirklich eine Regel **verkörpert** wurde; eine
Fähigkeit zu verdrahten ist das nicht automatisch. Ein hier vorab gesetztes Feld behauptete einen
Zielort, bevor es ihn gibt.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **(1) Der Aktivierungs-Schalter ist `dir`, nicht `mode` — und ein Block ohne ihn ist still
  grün.** Ist `dir` leer, öffnet die Fähigkeit kein Wellendokument; `mode: many` daneben ist
  wirkungslos, und der Lauf meldet `0 Befund(e)` in **beiden** Richtungen. Wer nur `mode` setzt
  und misst, liest daraus *„`waves` ist zahnlos"* — eine Zusicherung, die über der leeren Menge
  wahr ist. Das ist die gemessene Klasse
  [`BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr`](../observations/BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr/observation.md)
  (**1×**, `offen`).
  **Gegenmittel im Plan:** Liefer-Punkt (2) macht das Rot zur **Bedingung** der Verdrahtung, nicht
  zur Beigabe; eine Null aus einem Lauf ohne `dir` belegt nichts. Wer die Null ohne das Rot
  berichtet, hat den Prüfbereich nicht gemessen, sondern die Abwesenheit eines Prüfbereichs.
  — **Ausgang: weiter offen → Beobachtungs-Register**
  ([`BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr`](../observations/BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr/observation.md),
  Zähler damit **2×**). Auf **seiner** Achse hat das Gegenmittel getragen: Der Trockenlauf lief mit
  gesetztem `dir`, Richtung A ist real rot, und die Inertheit ohne `dir` ist eigens gemessen
  (`1260 Datei(en) geprüft, 0 Befund(e)`, Review-Runde 1, Negativbefund N-5). Eingetreten ist die
  Klasse auf einer **zweiten** Achse, die dieser Plan nicht benannt hatte: Beide Deckungs-Träger
  sagten zu, `waves` lese die Vorschau-Tabelle *Nächste Wellen* nicht — wahr allein deshalb, weil
  in deren Spalte 1 derzeit kein Name mit vorhandener Datei steht. Für diese Achse besteht kein
  Träger; der Zähler trägt sie.
- **(2) Die heutige Null hängt an der Form der Tabelle *Nächste Wellen*, nicht nur an der
  Zeiger-Liste.** Die Fähigkeit kennt neben `wave-drift` den Grund-Code `wave-preview-exists` —
  belegt in [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) §1, dessen Messung **2 ×** je
  Code über einem **anderen Baum und einem anderen Pin** führt und deshalb hier als datierter
  Beleg für die *Existenz* des Codes steht, nicht als Zahl über dem heutigen Bestand
  ([`MR-053`](../../../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)).
  Heute stehen unter *Nächste Wellen* nur **unverlinkte** Kandidaten ohne Datei, und
  die drei flachen Dateien haben je ihren Zeiger
  (`ls docs/plan/planning/welle-*.md | wc -l` → **3**;
  `sed -n '/^## Offene Wellen/,/^## /p' docs/plan/planning/in-progress/roadmap.md | grep -c '^- \[welle-'`
  → **3**). Die Aktivierung bindet damit einen **Planungs-Ablauf** mit: Eine Welle-Datei, die
  geschnitten wird, bevor ihr Start-Trigger eintritt, färbt den Gate ab dann rot. Das ist die
  gewollte Wirkung und keine Panne — aber sie trifft den nächsten Wellen-Schnitt, nicht diesen
  Slice, und sie gehört benannt, bevor sie jemanden überrascht.
  — **Ausgang: eingetreten → Folge-Slice `slice-wellen-schnitt-folgt-der-eroeffnungs-regel`.**
  Und schärfer als vorhergesagt: Getroffen ist nicht erst der nächste Wellen-Schnitt, sondern die
  Arbeitsweise selbst — [ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md)
  Festlegung 1 beendet den frühen Schnitt, und `wave-preview-exists` färbt ihn ab sofort rot. Drei
  lebende Träger lehren ihn weiterhin (`welle-13` §1, `roadmap.md` §Nächste Wellen,
  [`plan-welle.md`](../../../../.claude/commands/plan-welle.md)); der Folge-Slice liegt in `open/`
  und nimmt sie in einem Schnitt.
- **(3) Die Abweichungs-Frage ist nicht entschieden, und dieser Slice darf sie nicht
  entscheiden.** Entfällt die Abweichung mit der Aktivierung — dann ist kein Eintrag nötig —, oder
  besteht sie bis zu einem Eintrag fort? Beides ist Architect-Arbeit
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8), und der Adaptions-Block ist der Ort, an dem eine
  unerklärte Abweichung sonst zum Fork wird
  ([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)). **Übergabe-Artefakt
  ist dieser Plan**; die Antwort steuert die Rückführung `in-progress` → `open` in §4.
  — **Ausgang: entfallen.** Der Architect hat sie beantwortet:
  [ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 2 stellt fest,
  dass die Abweichung nicht besteht und nie gebucht war — ein Eintrag entsteht nicht. Die Antwort
  lautete damit *entfällt* und nicht *braucht vorher einen Eintrag*; die Rückführung aus §4 ist
  nicht eingetreten. Wieder auftreten kann die Frage nicht: Die Entscheidung steht auf `Accepted`
  und ist nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefroren, ein Widerspruch geht den
  Folge-ADR-Weg mit neuer Evidenz.
- **(4) Die Zusage kann mehr behaupten, als die Fähigkeit hält.** Von den zwei Richtungen der
  Bijektion trägt `waves` nur eine: Ein **Zeiger ohne Datei** fällt über das Modul `links`
  (`target-missing`), nicht über `waves`. Wer nach der Aktivierung schreibt *„die Bijektion ist
  bewacht"*, nennt einen Sensor für eine Form, die er nicht sieht — die Klassen
  [`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  (**14×**, `geplant`) und
  [`BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene`](../observations/BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene/observation.md)
  (**3×**, `offen`). **Gegenmittel im Plan:** Liefer-Punkt (3) verlangt die Grenze ausdrücklich im
  Text, nicht als Fußnote.
  — **Ausgang: weiter offen → Beobachtungs-Register**
  ([`BEO-ALL/zusammenfassung-staerker-als-ihre-quelle`](../observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md),
  **7×**, und
  [`BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine`](../observations/BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine/observation.md),
  **2×**). Eingetreten ist es dreimal in zwei Runden, und jedes Mal an einer **anderen** Kante als
  der hier benannten: die Vorschau-Tabelle, über die beide Träger zu wenig zusagten (Runde 1,
  HIGH-1); der zusammenfassende Satz unter der Fünf-Lagen-Tabelle, der breiter stand als die
  Tabelle, die er zusammenfasst (Runde 2, MEDIUM-1); und *„`waves` hält **genau das** durch"* für
  eine Festlegung, von der die zitierte ADR ein Drittel als unbewacht führt (Runde 2, LOW-1). Das
  Gegenmittel hat die **eine** benannte Kante gehalten — die Grenze steht im Text — und über die
  Zusage als Ganzes nichts gesagt. **Und die Prämisse dieses Risikos ist selbst widerlegt:**
  `waves` trägt **beide** Richtungen der Bijektion; der Satz oben ist die Annahme, gegen die der
  Trockenlauf maß, und sein Ausgang steht in Risiko 5.
- **(5) Die Aussagen dieses Plans tragen zwei verschiedene Beleg-Grade, und der Unterschied steht
  hier statt im Fließtext.** **Belegt** sind alle repo-lokalen `grep`/`ls`/`sed`-Zahlen — jede
  steht neben dem Kommando, das genau sie ausgibt. **Angenommen** sind die drei d-check-Ergebnisse
  (unveränderter Bestand `0 Befund(e)`, Richtung A `wave-drift`, Richtung B über `links`): Ein
  Docker-Lauf gehört zur Umsetzung und nicht zum Schnitt, und ein Plan, der sie als eigene Messung
  ausgäbe, träfe
  [`BEO-ALL/gruen-aussage-ohne-herkunft`](../observations/BEO-ALL/gruen-aussage-ohne-herkunft/observation.md)
  (**2×**, `offen`) — dieselbe Unterscheidung *gemessen* gegen *belegt*. §3 macht ihr Nachfahren
  zum ersten Schritt der Umsetzung; kippt eines davon, greift eine der zwei Rückführungen in §4.
  — **Ausgang: weiter offen → Beobachtungs-Register**
  ([`BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt`](../observations/BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt/observation.md),
  neu angelegt, **1×**). Eingetreten ist es: Von den drei angenommenen d-check-Ergebnissen ist
  eines gekippt — Richtung B fällt über `waves` und nicht über `links`. Die hier angekündigte Folge
  ist **nicht** gefolgt, und zu Recht: Die zwei Rückführungen in §4 messen Größe und Blockade, und
  eine gekippte Annahme bewegt weder Liefer-Punkte noch Schichten. Gekostet hat sie trotzdem, weil
  sie nicht nur hier stand, sondern in **DoD (3)** — dort hat sie zwei Review-Runden und alle vier
  Commits überlebt, weil ihre Korrektur in keinen der drei ausführenden Kontexte gehört
  ([`AGENTS.md`](../../../../AGENTS.md) §3.10). Der Planner hat den Punkt mit dieser Closure auf
  die gemessene Grenze berichtigt; ein Träger, der die Annahmen eines Plans **vor** dem Abhaken
  gegen die Messungen desselben Vorgangs hält, besteht nicht.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** **Die Reihenfolge aus §3 — erst der Trockenlauf, dann die Config.** Sie
  hat die falsche Plan-Annahme zu Richtung B gefunden, **bevor** verdrahtet wurde, und die
  Sensor-Prosa ist gegen die Messung geschrieben statt gegen den Plan. Zweitens die Kopplung
  *Rot ist Bedingung, nicht Beigabe*: `dir` ist der Aktivierungs-Schalter, und ein Lauf ohne ihn
  meldet in beiden Richtungen null — ohne den roten Gegenlauf wäre die Aktivierung an einer
  Zusicherung über der leeren Menge vorbeigegangen.
- **Was ging anders als geplant:** **Dreierlei.** (a) Die Fähigkeit deckt **mehr**, als der Plan
  annahm — `wave-drift` trägt beide Richtungen unter *Offene Wellen*, und als Folge derselben
  Aktivierung hält sie zusätzlich *Abgeschlossene Wellen* gegen die Ergebnisnotizen
  (`wave-unregistered`/`wave-results-missing`) und liest Spalte 1 der Vorschau
  (`wave-preview-exists`). Vier Grund-Codes statt des einen, den der Plan kannte. (b) Die
  Abweichungs-Frage, die §6 Risiko 3 an den Architect übergab, war zum Zeitpunkt der Übergabe
  faktisch schon entschieden: Die Verdrahtung färbt den abweichenden Zustand rot. (c) Die
  Plan-Annahme zu Richtung B stand nicht nur in §6, sondern in **DoD (3)**, und dort hat sie alles
  überlebt — die Korrektur des Abnahmekriteriums gehört dem Planner
  ([`AGENTS.md`](../../../../AGENTS.md) §3.10), und keine der ausführenden Rollen durfte sie
  vornehmen. Sie steht mit dieser Closure.
- **Steering-Loop-Eintrag:** **Neuer Sensor** — die **Listen-Hälfte** des Abschnitts *Offene
  Wellen* ist bewacht: `planning.waves` (`dir` + `mode: many`) hält die Bijektion zwischen den
  Zeigern dort und den flachen Welle-Dateien in **beiden** Richtungen (`wave-drift`), dazu
  *Abgeschlossene Wellen* gegen die Ergebnisnotizen und Spalte 1 der Vorschau. Was er **nicht**
  sieht, steht daneben: eine Nennung in Spalte 3 und ein toter Vorschau-Zeiger ohne Datei — der
  fällt über `links`. Das ist der Weg, den
  [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  §Begründung einem Gate-*Anheben* zuweist.
  *(Kein `liegt in`-Feld: Mit diesem Slice ist keine Regel aus einem 3×-Übertritt **verkörpert**
  worden. Der Sensor folgt aus
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) und
  [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  und trägt damit bereits eine ID — Baseline-Regelwerk `grundlagen-traceability.md`
  §Herkunfts-Anker, Geltungsbereich. Der Eintrag ist gezählt, nicht verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** **elf Belege, je einer je Klasse** — drei
  Verzeichnisse neu angelegt, acht `evidence/slice-offene-wellen-liste-hat-einen-waechter.md`
  ergänzt. Neu: `abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt` (1×, aus der
  Verifikation), `aktivierung-entscheidet-die-als-offen-uebergebene-frage` (1×, aus Runde 1 HIGH-2
  — und die Kennungs-Entscheidung, die
  [ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Konsequenzen dieser
  Closure ausdrücklich überlässt), `naechste-rolle-uebernimmt-vor-dem-schluss-der-vorigen-runde`
  (1×, aus der Verifikation). Ergänzt: `zusicherung-ueber-der-leeren-menge-wahr` (2×),
  `mutations-fall-ueberlebt-die-umbenennung-seines-waechters` (2×),
  `zusammenfassung-staerker-als-ihre-quelle` (7×), `zusage-nennt-zwei-kanten-der-sensor-deckt-eine`
  (2×), `praesens-aussage-in-einzufrierendem-artefakt-ohne-form` (2×),
  `zusage-neben-geaenderter-ableitung-bleibt-stehen` (24×),
  `beleg-nach-dem-ausgang-findet-keinen-leser` (2×) und —
  **strukturell erst nach dem `git mv`, weil er ein Befund des Move ist** —
  `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` (16×): Der Closure-Move macht die Zeile
  *„In Arbeit: …"* der Roadmap falsch, und [`make slice-mv`](../../../../harness/sensors/slice-mv.md)
  zieht Pfade nach, keine Zustandssätze.
  **Nicht gebucht ist `verweis-nachzug-ersetzt-eine-historisch-richtige-adresse`**, und das ist
  gemessen: Der Nachzug hat in den drei Review-Reports je **eine** Zeile ersetzt, und alle drei
  sind Metadaten-Zeiger (*Slice-Plan* / *Eingangs-Kontext*), keine Mess-Aussage über die
  Vergangenheit — genau der Fall, für den
  [ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1 die
  Ersetzung als richtig setzt.
  **Zwei Einordnungen weichen von der Empfehlung des Reports ab**, und der Grund steht hier:
  Runde-2-INFO-1 ist **nicht** unter `benannte-luecke-ohne-ausgang` gebucht — jene Klasse handelt
  von einer Grenz-Beschreibung in lebender Prosa, hier altert eine **Präsens-Aussage in einem
  einfrierenden Artefakt**, was genau die andere Klasse trifft. Runde-2-INFO-2 ist **nicht** unter
  `ueberholter-offener-plan-ohne-genormten-ausgang` gebucht: Jene Klasse handelt vom **Ausscheiden**
  eines Plans, für das keine Quelle einen Weg nennt;
  [slice-210](../open/slice-210-planning-modul-im-emittierten-doc-gate.md) scheidet nicht aus, sein
  Gegenstand steht — nur eine Begründung daneben ist falsch geworden, und dafür gibt es einen
  Ausgang, den diese Closure geht.
  **Kein Eintrag erreicht mit diesem Slice 3×**; drei standen schon davor darüber. Den Lese-Schritt
  trägt in diesem Repo die Welle-Closure.
- **Folge-Slices:** zwei, beide als Datei in `open/`.
  [`slice-wellen-schnitt-folgt-der-eroeffnungs-regel`](../done/slice-wellen-schnitt-folgt-der-eroeffnungs-regel.md)
  — die drei Planner-Folgepflichten aus
  [ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Konsequenzen in einem
  Schnitt (§6 Risiko 2). Und
  [`slice-migration-hat-ein-instanz-register`](../done/slice-migration-hat-ein-instanz-register.md)
  — das vom Auftraggeber bestellte stehende `harness/migration.md`, dem nächsten Baseline-Sprung <!-- d-check:ignore (geplante Datei) -->
  vorgelagert; er hängt an diesem Slice nicht und steht hier, weil diese Closure ihn geschnitten
  hat.
- **Zwei Übergaben ohne eigenen Folge-Slice, beide hier abgetragen:** (a) Die
  Folgepflicht aus [ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md)
  §Konsequenzen **ohne Rollen-Adresse** — der Absatz in
  [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md), der die Norm-Frage
  als offen führte — ist mit Commit `87557369` **eingelöst**: Der Absatz ist ersetzt und zeigt auf
  die Entscheidung (`grep -rl 'offene Norm-Frage' harness/ | wc -l` → **0**, kein
  Erwartungswert). Die ADR steht auf `Accepted` und wird die Pflicht weiter als fällig führen; das
  ist der Preis von [`AGENTS.md`](../../../../AGENTS.md) §3.4 und wird nicht geheilt, sondern hier
  vermerkt. **Nicht** eingelöst sind die drei übrigen — sie sind der Folge-Slice oben. (b) Der
  überholte Ausschluss-Punkt in
  [slice-210](../open/slice-210-planning-modul-im-emittierten-doc-gate.md) §1 ist nachgezogen; der
  Ausschluss selbst bleibt, seine Begründung nennt jetzt die drei Kriterien von
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  statt einer Abweichung, die es nicht gibt.
- **Prozess-Hinweis aus der Verifikation (V-4), ohne Diff-Folge:** Review-Runde 2 endete
  `BLOCKIERT`, und eine dritte Runde, die die Nacharbeit freigibt, hat nicht stattgefunden — die
  Verifikation hat sie selbst am Diff nachvollzogen. Kein DoD-Punkt verlangt eine Freigabe-Runde
  wörtlich; die Beobachtung ist als eigene Kennung im Register und nicht als Nacharbeit gebucht.
- **Risiken aus §6:** fünf Risiken, fünf Ausgänge — einmal *eingetreten* (Risiko 2 → Folge-Slice),
  einmal *entfallen* mit Begründung (Risiko 3), dreimal *weiter offen* ins Beobachtungs-Register
  (Risiken 1, 4, 5). Kein Risiko ohne Ausgang; die Einzelheiten stehen in §6.
- **Drei Paarungen:** Repo **mit** Wellen-Betrieb (`ls docs/plan/planning/welle-*.md | wc -l` →
  **3**, kein Erwartungswert) — geprüft von der nächsten Welle-Closure, auch für diesen Slice ohne
  Wellen-Zugehörigkeit.

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
([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
für jede Schärfung dieses Gates,
[`MR-052`](../../../../harness/conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte)
für den Stand, auf dem die Fähigkeit verfügbar ist), eigener Prüfbereich
([`make docs-check`](../../../../harness/sensors/docs-check.md) über dem gesamten Doku-Bestand) und
eigene Fehlermodi (ein Modul, das ohne seinen Schalter still grün meldet — §6, Risiko 1).
**`TOOLS` ist geprüft und nicht berührt:** Keine Aussage über `harness/tools/` ändert sich; dass
`harness/tools/` Skripte für andere Gate-Ziele trägt, ist Pfad-Nähe und nicht hinreichend.
**`CODEX` ebenso wenig** — `.codex/` führt allein den SessionStart-Injektor.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist am gemergten Stand durchgegangen
— **101** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, **kein
Erwartungswert**, [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2: ein Zähler-Stand ist eine datierte Messung); alle führen dieselbe Sub-Area `*`, die
Sichtung ist damit vollständig. **Sechs Treffer** berühren diesen Slice:

| Beobachtung (`BEO-ALL/<slug>`) | Zähler | Stand | wo sie diesen Slice trifft |
|---|---|---|---|
| `zusage-nennt-sensor-der-form-nicht-sieht` | 14× | geplant (`slice-181`) | §6 Risiko 4 — die Zusage nach der Aktivierung |
| `vollstaendigkeits-zusage-misst-falsche-ebene` | 3× | offen | §6 Risiko 4 — eine Richtung ist gedeckt, nicht die Bijektion |
| `gruen-aussage-ohne-herkunft` | 2× | offen | §6 Risiko 5 — *gemessen* gegen *belegt* bei den drei d-check-Zahlen |
| `register-paarung-ohne-gate-modul` | 1× | offen | §1 — die Schwester-Fähigkeit, deren `state.md` denselben Anhebungs-Weg führt |
| `vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut` | 1× | offen | §8 Evidenz-Risiko — das gepinnte Bild kann es, nur ruft es keine Config |
| `zusicherung-ueber-der-leeren-menge-wahr` | 1× | offen | §6 Risiko 1 — der Lauf ohne `dir` ist genau diese Klasse |

```sh
for s in zusage-nennt-sensor-der-form-nicht-sieht vollstaendigkeits-zusage-misst-falsche-ebene \
         gruen-aussage-ohne-herkunft register-paarung-ohne-gate-modul \
         vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut \
         zusicherung-ueber-der-leeren-menge-wahr; do
  printf '%s %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" "$s"
done
```

**Keiner der sechs erreicht mit diesem Slice 3×** — die zwei über der Schwelle standen **vor** ihm
dort und haben ihren Ausgang bzw. warten auf den Lese-Schritt, den in diesem Repo die
Welle-Closure trägt und nicht diese Planung. **Ein eigener Folge-Slice entsteht aus der Sichtung
also nicht.** Die vier darunter sind das Evidenz-Risiko unten und stehen als vorab benannte
Risiken in §6 — dort, wo sie einen Ausgang bekommen, statt nur zitiert zu werden.

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas sind Greenfield; der Block trägt
eine Sub-Area.

### Sub-Area: `*` (gesamtes Repo, Kürzel `ALL`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — der Weg einer Gate-Schärfung ist in
  [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  geregelt (Trockenlauf, Config-Entscheidung, Steering-Loop statt ADR), der Stand des Werkzeugs in
  [`MR-052`](../../../../harness/conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte),
  und die Regel, dass eine Werkzeug-Aussage datiert statt den lebenden Pin zu führen, in
  [`MR-053`](../../../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen).
  Der Gegenstand selbst — die Marker-Hälfte desselben Blocks — ist mit
  [slice-125](../done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) bereits einmal
  denselben Weg gegangen.
- **Phase-Reife:** Phase 4 für das Doku-Gate — acht aktive Module
  (`grep -m1 '^modules:' .d-check.yml | tr ',' '\n' | wc -l` → **8**), jedes mit dokumentiertem
  Prüfbereich in [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md), und
  die Grenzen sind dort benannt statt verschwiegen. Was zu Phase 5 fehlt, ist genau die hier
  behandelte Hälfte: eine Zusage, die heute als *unbewacht* dasteht.
- **Evidenz-/Diskrepanz-Risiko:** **mittel**, und die Belege sind die drei einzelnen Treffer der
  Sichtung oben. Die tragende Diskrepanz ist nicht Doku gegen Code, sondern **Prosa gegen
  Fähigkeit**: Das gepinnte Bild kann die Prüfung, und die Begründung für ihr Ausbleiben stand in
  einer Datei, die den Text nicht mehr trägt (`grep -c 'waves' harness/README.md` → **0**, während
  der `planning`-Kommentar der [`.d-check.yml`](../../../../.d-check.yml) viermal dorthin zeigt).
  Genau das ist
  [`BEO-ALL/vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut`](../observations/BEO-ALL/vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut/observation.md)
  (**1×**) eine Ebene weiter: nicht von Hand nachgebaut, sondern gar nicht getan. Die Inventur,
  die das sichtbar macht, ist der Trockenlauf aus §3 — und sein Ergebnis kann die Rückführung
  `in-progress` → `next` auslösen (§4).
- **Reconciliation-Aufwand:** keiner — GF, kein Inventur-Fund im Sinne des
  Reconciliation-Registers; die Datei `reconciliation.md` existiert in diesem Repo nicht
  (`ls docs/plan/planning/reconciliation.md` → Exit 2), und das zugehörige DoD-Item entfällt
  deshalb in §2. Graduation entfällt (n/a bei GF). Der Trigger, der die Achse auf Phase 5 höbe,
  ist ein Wächter für die **zweite** Richtung dieser Bijektion aus demselben Modul; heute trägt
  sie `links`, und das ist in §2 Liefer-Punkt (3) als Grenze zu schreiben, nicht als Deckung.

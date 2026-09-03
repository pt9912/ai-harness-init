# Slice slice-164: Der Emitter klassifiziert die zwei neuen Archiv-Stub-Vorlagen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-14](../welle-14-re-baseline.md).

**Bezug:** [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
(die zweiklassige Template-Ablage ist die Zusage, die der Emitter hält),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(der Fixture-Wächter ist der Sensor, der die Klasse laut hält).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**`archiv-stub-slice.template.md` und `archiv-stub-welle.template.md` tragen im Emitter eine
Klassen-Entscheidung — in scope oder nicht, Singleton oder wiederkehrend —, und
`test/courseset-fixture.bats` ist wieder grün.**

Der Tausch auf `v5.18.0` ([slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md)) hat
den vendored Satz um zwei Vorlagen erweitert; der Emitter führt sie in keiner seiner drei Listen.
Gemessen im Tausch-Lauf: `make -k gates` meldet `not ok 40` (`courseSet()` gegen den realen Satz),
`not ok 41` (`in-scope-Templates: 23, erwartet 21`) und `not ok 43` (`isRecurring` liest
`OHNE-ZIEL:` für beide neuen Vorlagen). Die Zahlen wandern mit dem Satz und sind keine
Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Dieselbe Klasse wie [`CO-004`](../../carveouts/done/CO-004-emitter-klassifikation-offen.md) beim
letzten Sprung**, dort mit [slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md)
aufgelöst — und dort wie hier gilt: der Tausch **stellt** die Frage, er beantwortet sie nicht.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **Beide Vorlagen tragen ein Verdikt je Achse** — in scope / außer scope, und bei in scope
      Singleton oder wiederkehrend —, jedes mit dem Grund am Fundort und nicht in diesem Plan.
- [x] **`test/courseset-fixture.bats` ist grün**, und das Grün ist nicht durch Anpassen der
      Erwartung erkauft: die Fixture folgt der Entscheidung, nicht umgekehrt. Rot gesehen
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6) ist das Gegenbeispiel — eine dritte Vorlage im
      Satz, die in keiner Liste steht, färbt dieselben Fälle.
- [x] `make gates` grün.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates.go` | update | `inScope` und `isRecurring` treffen die Entscheidung |
| `internal/emit/templates_test.go` | update | `courseSet()` bildet den realen Satz ab |
| `test/courseset-fixture.bats` | update | der Wächter, der heute rot steht |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md)
liegt in `done/` — erst dann ist der Satz, gegen den klassifiziert wird, der adoptierte.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Klassen-Entscheidung eine
  Änderung am Emissions-**Verhalten** verlangt (eine neue Idempotenz-Klasse, ein neuer Zielort)
  statt einer Eintragung in bestehende Listen.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Frage *gehört die Stub-Form überhaupt
  in ein emittiertes Repo?* offen ist — das entscheidet
  [slice-158](../open/slice-158-archivierungs-schritt.md) für die Dogfood-Ebene, und ohne dessen Verdikt
  klassifiziert dieser Slice gegen eine ungeklärte Zusage.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Das Grün entsteht durch Anpassen der Erwartung statt durch eine Entscheidung** — die Fixture
  ist eine Liste, und eine Liste lässt sich immer passend machen. — **Ausgang: entfallen.** Die
  Erwartungs-Zahl folgt der Entscheidung: beide Vorlagen bleiben in scope, also zählt der Satz
  **23** statt 21
  (`find .harness/baseline/*/templates -type f -name '*.template.md' | grep -v '/project-readme' | wc -l`;
  kein Erwartungswert,
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Dass der Wächter danach noch misst, ist rot gesehen (§7).
- **Die Entscheidung hängt an [slice-158](../open/slice-158-archivierungs-schritt.md)** und kann ins Leere
  laufen, wenn dort der Archivierungs-Schritt für dieses Repo verworfen wird. — **Ausgang:
  entfallen.** *Wiederkehrend* ist die Klasse, die **nichts** ins frische Zielrepo legt; sie sagt
  über dessen Betrieb nichts aus. Dieselbe Klasse tragen `welle.template.md` und
  `welle-results.template.md`, ohne dass ein Zielrepo Wellen fahren müsste. `slice-158` entscheidet
  die Dogfood-Ebene und berührt diese Klasse nicht.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Rolle:** Implementer. **Datum:** 2026-09-03.

**Das Verdikt, beide Achsen, für beide Vorlagen: in scope · wiederkehrend.** Der Grund steht am
Fundort (`emit.isRecurring`, Rumpf und Kommentar) und ruht auf zwei Belegen: Beide nennen ihren
Ziel-Ort als Verzeichnis mit Platzhalter — `docs/plan/planning/done/<welle-id>/`, je archiviertem
Slice bzw. Welle-Plan einer —, und der Set-Index des vendored Satzes
(`.harness/baseline/v5.18.0/templates/README.md` §Ein- vs. wiederkehrende Templates) führt beide
ebenfalls unter den Wiederkehrenden. *Wiederkehrend* heißt: nicht emittiert, aus dem vendored Satz
je Artefakt kopiert; ein frisch gebootstrapptes Zielrepo bekommt keine co-located Kopie.

- **Was hat funktioniert:** Der Wächter hat seine Frage gestellt, statt das Neue still als Singleton
  durchzulassen — genau die drei Fälle, die sein eigener Kommentar ankündigt. Das Gegenbeispiel ist
  gefahren: eine dritte, unklassifizierte Vorlage im vendored Satz färbt `not ok 40`, `41` und `43`
  und keinen weiteren Fall; danach wieder entfernt. Die Entscheidung selbst ist rot gesehen über
  drei neue Fälle in `test/mutations/` (222/223: ein Eintrag fällt aus `emit.isRecurring` → die
  Vorlage wird als Singleton emittiert, `TestTemplates_EmittierterBestandVollstaendig` rot · 224:
  der Ziel-Ort verliert seinen Platzhalter → die Ableitung sagt *nicht wiederkehrend*, die dritte
  Achse rot).
- **Was ging anders als geplant:** Drei Abweichungen, alle benannt statt weggedeutet. (1) Der
  **Start-Trigger** aus §4 verlangt `slice-156` in `done/`; beim Übergang lag er noch in
  `in-progress/`. Getragen hat die Sachbedingung dahinter — der vendored Baum steht auf `v5.18.0`
  (`ls -d .harness/baseline/*/`) —, und `slice-156` ist inzwischen geschlossen. (2) Das **WIP-Limit**
  war beim Übergang nicht frei: `in-progress/` trug `slice-156` und `slice-164` nebeneinander.
  (3) Die dritte Achse konnte die zwei Vorlagen **nicht ableiten** — ihr Leser kannte nur den
  Kopiere-Satz und meldete für beide `OHNE-ZIEL:`. Das ist kein Defekt des Wächters, sondern die
  Grenze, die sein eigener Kommentar als *laut statt still* benennt; der Leser liest jetzt beide
  Satzformen (`ziel_ort`).
- **Steering-Loop-Eintrag:** Sensor ergänzt: `test/courseset-fixture.bats` leitet die
  wiederkehrenden Vorlagen aus **zwei** Satzformen des Template-Hinweises ab — Kopiere-Satz und
  Verbleib-Satz —, jede mit eigener Endungs-Bedingung (`.md` bzw. `/`); eine dritte Form fällt
  weiter als `OHNE-ZIEL:` auf. Dazu drei Fälle in `test/mutations/` (222, 223, 224).
- **Beobachtungs-Register (`../observations.md`):** keine Beobachtung angefallen — das Register
  bleibt unverändert. Zwei Kandidaten sind geprüft und **verworfen**, beide mit Messung statt
  Eindruck: (a) *die bats-Funktion `in_scope` ist eine zweite Fassung von `emit.inScope` ohne
  Wächter* — trägt nicht, denn eine einseitige Verengung von `emit.inScope` färbt die dritte Achse
  rot (die Vorlage bliebe in der Ableitung und fehlte in der Aufzählung); (b) *eine Mutation
  verankert auf einer Quellzeilen-Form und wird von einem Nachbar-Eintrag still entschärft* — trägt
  nicht, weil `make mutate` einen zahnlosen Fall meldet; die Kopplung steht jetzt als Kommentar an
  `emit.isRecurring`. `BEO-010` (Nachzügler einer Re-Baseline) trifft die Klasse dieses Slice; ob er
  der dritte Übertritt ist, entscheidet nach §8 die Closure von
  [welle-14](../welle-14-re-baseline.md) — hier wird der Zähler darum nicht bewegt.
- **Folge-Slices:** keine. Die Lücke in
  [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) — die
  Aufzählung nennt vier der neun wiederkehrenden Vorlagen nicht — hat ihren Träger bereits in
  [slice-139](../open/slice-139-lastenheft-deckt-die-emit-disposition.md); ein zweiter wäre eine
  zweite Adresse für dieselbe Sache.
- **Risiken aus §6:** zwei, je genau ein Ausgang, beide **entfallen** — mit Messung in §6 selbst.
- **Drei Paarungen:** nicht hier fällig. Dieser Slice ist Mitglied von
  [welle-14](../welle-14-re-baseline.md) §4; Anker, Folge-Slice und Register prüft deren Closure.
  Was sie von hier erbt: **ein** Steering-Loop-Eintrag ohne `liegt in` (gezählt, nicht verkörpert),
  **null** *weiter offen*-Ausgänge, **null** neue Folge-Slices, **keine** neue `BEO-<NNN>`.

**Sensor-Belege dieses Laufs.** `make gates` Exit **0** (`baseline-verify: v5.18.0 OK — 53 Dateien`,
`d-check: 505 Datei(en) geprüft, 0 Befund(e)`, `comment-claims: 47 Datei(en) geprueft, 0 Befund(e)`,
`1..206` in der bats-Stufe, darunter `ok 40`–`ok 44`). `make smoke` Exit **0**, das emittierte
`docs-check` meldet `20 Datei(en) geprüft, 0 Befund(e)`. `make mutate` Exit **0**,
`217 ok, 0 Befund(e)`, darunter die drei neuen Fälle je mit ihrem rot gefärbten Sensor. Ein
erster Lauf meldete `1 Befund(e)` `host-baum`: eine Mutations-Zieldatei änderte sich unter ihm
(`harness/conventions.md`, von einem parallelen Architect-Commit), also ist er kein Verdikt und
wurde über ruhendem Baum wiederholt. Alle Zahlen wandern mit dem Baum und sind keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die Modus-Deklaration
in [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
führt für `internal/emit/` keine engere.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-010` (Nachzügler einer Re-Baseline) trifft
diesen Slice direkt — er **ist** ein Nachzügler; der Zähler-Stand steht im
[Register](../observations.md), das Urteil über den dritten Übertritt fällt die Closure von
[welle-14](../welle-14-re-baseline.md). Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.

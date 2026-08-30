# Slice slice-139: Das Lastenheft deckt, was der Emitter über eine Vorlage entscheidet

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle (reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — ein Slice, einzeln lieferbar, er wartet auf
keinen zweiten. **(2) Gemeinsames Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift
seiner eigenen DoD. **(3) Auslöser reaktiv oder gewollt?** Reaktiv: ein Review-Lauf hat gemessen,
dass zwei Aussagen der Anforderung den Emitter nicht mehr decken. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: das Werkzeug, nicht der Dogfood.** Gegenstand ist die Anforderung, die der Emitter
erfüllt, und der Emitter selbst. Was dieser Slice ändert, geht in **jedes** gebootstrappte Repo —
nicht als Text, sondern als Emit-Verhalten.

**Bezug:**
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (die
zweiklassige Ablage — die Anforderung, deren Aufzählung und deren Dispositions-Menge hier gemessen
werden),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Anforderung, die eine Aufzählung führt, die der Code nicht mehr trifft, sagt eine Deckung zu, die
nicht besteht — dieselbe Klasse eine Ebene über dem Gate),
[`ADR-0005`](../../adr/0005-ziel-repo-distribution.md) (wiederkehrende Vorlagen werden
referenziert, nicht co-located emittiert — die Entscheidung, aus der beide Aussagen stammen),
[`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) (nennt dieselbe Menge und ist
`Accepted`, also immutabel — §6),
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
(*„weder ADR noch Slice dürfen `LH-*` je ändern"* — der Grund, warum die Vertragsänderung hier
**Vorbedingung** ist und kein Liefer-Punkt),
[`AGENTS.md`](../../../../AGENTS.md) §3.4 (ADRs sind nach Accepted immutabel),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (der Wächter aus DoD (1) nennt, was ihn rot färbt),
[`AGENTS.md`](../../../../AGENTS.md) §3.7 (ein Kommentar sitzt in keinem Rang — der Grund, warum
die fünfte Disposition am Code kein Ersatz für eine Aussage in Rang 1 ist),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie ausgibt).

**Berührte Spec-Stellen:**
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) — ihre
namentliche Aufzählung der wiederkehrenden Vorlagen und ihre Dispositions-Menge; dazu die
Glossar-Zeile *Wiederkehrendes Template* in §6 derselben Datei. Der Verweis zeigt **aufwärts**:
das Lastenheft nennt diesen Slice nie.

**Verantwortlich:** — (bis zur Priorisierung).

**Autor:** Planner. **Datum:** 2026-08-30.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Was der Emitter über eine Vorlage entscheidet, steht in
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) — und ein
Wächter hält beide gegeneinander, statt die Deckung zu unterstellen.**

### Zwei Lücken, beide gemessen

**Erstens: die namentliche Aufzählung ist kürzer als der Code.** Die Anforderung führt **fünf
wiederkehrende** Vorlagen, `emit.isRecurring` **sieben wiederkehrende** — dieselbe Menge, zwei
Stände. Der Befund stammt aus dem Review-Durchgang zu
[slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md), dessen §6
Risiko 1 als Ausgang eine nachzutragende Slice-ID verlangt; **dieser Slice ist sie.** Beide Mengen
mit ihrem Kommando — die Aufzählung ist über zwei Zeilen umbrochen, das Kommando zieht sie deshalb
erst zusammen:

```sh
sed -n '/^### LH-FA-02/,/^### LH-FA-03/p' spec/lastenheft.md | tr '\n' ' ' \
  | grep -o 'Wiederkehrende\*\* Vorlagen ([^)]*)' | grep -o ' · ' | wc -l        # -> 4 Trenner = 5 Glieder
awk '/^func isRecurring/,/^}/' internal/emit/templates.go \
  | grep -o '"[A-Za-z-]*\.template\.md"' | wc -l                                 # -> 7
```

Die zwei, die dazugekommen sind, nennt dasselbe `awk`-Kommando ohne `wc`:
`welle-results.template.md` und `MR-NNN-titel.template.md`. **Beide Zahlen wandern** und sind
keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die eine mit dem vendored Satz, die andere mit dem Emitter.

**Zweitens: der Emitter kennt eine Disposition, die die Anforderung nicht führt.** Drei Weichen
entscheiden über die Ablage einer Vorlage, die vierte Disposition ist ihre Voreinstellung:

```sh
grep -cE '^func (isRecurring|isDerivativeIndex|isBrownfieldOnly)\(' internal/emit/templates.go   # -> 3
```

*Wiederkehrend* und *derivativer Index* nennt
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), *Singleton*
auch. Die dritte — **gar nicht emittiert** — nennt sie nicht:
`grep -ci 'brownfield' spec/lastenheft.md` → **0** und `grep -c 'reconciliation' spec/lastenheft.md`
→ **0**. Sie steht heute allein am Code-Kommentar der Weiche, und
[`AGENTS.md`](../../../../AGENTS.md) §3.7 sagt seit dem 2026-08-30, dass ein Kommentar in keinem
Rang sitzt: der nächste Lauf liest ihn als Beleg und beruft sich auf eine Quelle, die keine ist.

**Dieselbe Lücke trägt eine zweite Aussage, und sie ist der eigentliche Grund für diesen Schnitt.**
Ob diese vierte Disposition eine **Abweichung** von der Baseline ist, hat der Architect entschieden
— sie ist keine, und
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) gilt fort. Ein lebendes
Artefakt führt die Entscheidung nicht:
`git grep -n 'isBrownfieldOnly' -- docs/plan spec harness AGENTS.md` liefert nur Zeitdokumente,
und [`ADR-0025`](../../adr/0025-register-mit-gemischten-originalen.md) hat einen anderen Gegenstand
(`grep -ci 'brownfield' docs/plan/adr/0025-register-mit-gemischten-originalen.md` → **0**).
**Mit der Vertragsänderung fällt die Frage weg statt beantwortet zu werden:** eine Disposition, die
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) selbst
führt, ist keine Abweichung von einem Vorlagen-Satz — sie ist die Anforderung. Bis dahin ist die
Lücke **benannt** (hier), nicht geschlossen.

**Drittens, und es ist dieselbe Ursache:** die Glossar-Zeile *Wiederkehrendes Template* sagt
*„bleibt co-located für spätere Instanzen"* (`grep -c 'bleibt co-located' spec/lastenheft.md` →
**1**), während dieselbe Datei in
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
*„referenziert, nicht co-located dupliziert"* sagt. Rang 1 widerspricht sich in einer Datei.

### Warum die Vertragsänderung hier Vorbedingung ist und kein Liefer-Punkt

[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
zitiert die Baseline verbatim: *„weder ADR noch Slice dürfen `LH-*` je ändern — sie referenzieren
nur."* Setzung 1 legt den annehmenden Akt in die **Nutzer-Entscheidung**, Setzung 2 in einen
eigenen Commit, der **ausschließlich** `spec/lastenheft.md` ändert und **vor** dem
`open → in-progress`-Move dieses Slice liegt. Dieser Slice schreibt den Vertrag also nicht; er ist
der *umsetzende Slice*, den jene Setzung voraussetzt, und §4 macht die Bedingung zum Start-Trigger.

**Was er liefert, ist das, was heute niemand liefert:** den Wächter. Kein Modul von
`.d-check.yml` prüft die Vollständigkeit einer Aufzählung
(`grep -m1 '^modules:' .d-check.yml` → `links, anchors, ids, matrix, codepaths, spans`), und
`make comment-claims` prüft die Existenz eines genannten Sensors, nicht die Deckung zweier Mengen.
Ohne ihn wandert die Lücke beim nächsten Baseline-Bump wieder ein.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Ein Wächter hält die wiederkehrende Menge aus
      [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) gegen
      den Rumpf von `emit.isRecurring` — in beide Richtungen**, und ein `test/mutations/`-Fall
      färbt ihn rot. **Er misst die Aufzählung, nicht ihre heutige Länge:** eine Zahl im Test wäre
      genau der Erwartungswert, den
      [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2 ausschließt. Vorbild ist der Wächter in
      [`test/courseset-fixture.bats`](../../../../test/courseset-fixture.bats), der dieselbe Menge
      aus dem **vendored Satz** ableitet; dieser hier leitet sie aus **Rang 1** ab, und die zwei
      Quellen sind verschieden.
- [ ] **(2) Jede Weiche, die über die Emit-Disposition einer Vorlage entscheidet, ist einer Aussage
      in [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
      zugeordnet.** Vollständig über die Weichen, nicht über die auffälligen — der Nenner ist ein
      Kommando (`grep -cE '^func (isRecurring|isDerivativeIndex|isBrownfieldOnly)\(' internal/emit/templates.go`
      plus die Voreinstellung *Singleton*), keine Zahl in diesem Plan. Wo keine Aussage deckt,
      steht das als benannter Befund **mit Adressat**, nicht als Lücke.
- [ ] `make gates` bringt **keinen Befund hervor, der diesem Slice zuzurechnen ist** — Vorher-
      Nachher-Vergleich derselben Ausgabe, nicht „grün": der Lauf trägt fremde Posten mit eigenen
      Folge-Slices (§6).
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist. **Berührt ist einer** — der Vertrag
      selbst; er ist Vorbedingung (§4) und wird hier nicht geschrieben.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: das Repo hat keinen Brownfield-Bootstrap und führt keines; das Item
      entfällt mit diesem Grund, nicht still.
- [ ] Beobachtungs-Register: eine `observations.md` unter `docs/plan/planning/` existiert nicht
      (`ls docs/plan/planning/observations.md` → kein Treffer); ob sie entsteht, entscheidet
      [slice-137](../in-progress/slice-137-beobachtungs-register-bekommt-seinen-ort.md). Bis dahin entfällt das
      Item mit diesem Grund, und was aufgefallen ist, steht in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die nächste Welle-Closure — dieses
      Repo fährt Wellen-Betrieb, und die liest auch Slices ohne Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `test/` (Wächter-Datei, Zuschnitt offen) | neu | hält die Aufzählung aus Rang 1 gegen den Rumpf von `emit.isRecurring`; ob als `bats`-Fall neben dem vorhandenen Satz-Wächter oder als Go-Test, entscheidet der Lauf — die Quelle ist eine Markdown-Datei, nicht der `embed`-Baum |
| `test/mutations/` | neu | ein Fall, der die Aufzählung driften lässt und den Wächter rot färbt — ohne ihn ist DoD (1) eine Zusage ohne Gegenbeispiel ([`AGENTS.md`](../../../../AGENTS.md) §3.6) |
| `internal/emit/templates.go` | update | die Weichen-Kommentare zeigen auf die Aussage in Rang 1, die sie deckt, statt sie zu tragen ([`AGENTS.md`](../../../../AGENTS.md) §3.7) |
| `spec/lastenheft.md` | **unverändert durch diesen Slice** | Rang 1; die Änderung ist Vorbedingung und kommt aus einem eigenen Commit ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2) |
| [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) | **unverändert durch diesen Slice** | `Accepted` und damit immutabel ([`AGENTS.md`](../../../../AGENTS.md) §3.4); Korrektur entsteht als neue ADR beim Architect (§6) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **Der CR-Fußabdruck liegt vor** — ein Commit, der
**ausschließlich** `spec/lastenheft.md` ändert und dort die wiederkehrende Menge, die fehlende
Disposition und die Glossar-Zeile auf den Stand des Emitters bringt
([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
Setzung 2, Verweis-Form nach Setzung 3). Beobachtbar ohne Rückfrage:
`git log --format='%h %s' -- spec/lastenheft.md | head -1` benennt ihn, und
`git show --pretty=format: --name-only <sha> | grep -vc '^spec/lastenheft\.md$\|^$'` → **0** belegt
die Alleinstellung. **Ohne diesen Commit bleibt der Slice in `open/`** — nicht weil er zu groß
wäre, sondern weil sein Gegenstand ohne die Vertragsänderung nicht existiert.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der Wächter aus DoD (1) und die
  Dispositions-Zuordnung aus DoD (2) sich als zwei Sensoren über zwei verschiedenen Quellen
  erweisen — die eine liest eine Prosa-Aufzählung, die andere eine Weichen-Menge. Dann trennt der
  Schnitt sie.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Aufzählung in Rang 1 nach dem CR
  weiterhin **Begriffe** statt Dateinamen führt und die Abbildung auf Dateinamen eine dritte,
  eigene Quelle bräuchte. Eine dritte Quelle driftet gegen beide; dann geht die Frage zurück an den
  Vertrag, statt sie im Test zu erfinden.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **der Wächter aus DoD (1) läuft in `make gates` und ist über seinen
`test/mutations/`-Fall rot gesehen** (`make mutate` bestätigt den Fall als `ok`), und **jede der
Weichen aus DoD (2) trägt ihre Zuordnung**. Dazu die Closure-Notiz mit Steering-Loop-Lerneintrag
und je Risiko aus §6 genau ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Nutzer-Entscheidung bleibt aus.** Der Start-Trigger ist eine Bedingung außerhalb dieses
  Repos-Prozesses; ohne sie hat der Slice keinen Gegenstand, und ein Wächter über der heutigen,
  falschen Aufzählung wäre dauerhaft rot. — **Ausgang:** <entfallen: der CR-Commit liegt vor und
  ist benannt | eingetreten: CO-NNN mit Auflösungs-Trigger, solange der Vertrag die Menge nicht
  deckt>
- **[`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) nennt dieselbe Menge und ist
  `Accepted`.** Ihr Satz *„die fünf wiederkehrenden Vorlagen"* wird mit dem CR falsch
  (`grep -c 'die fünf wiederkehrenden Vorlagen' docs/plan/adr/0020-emittierte-modul-15-regeln.md`
  → **1**). [`AGENTS.md`](../../../../AGENTS.md) §3.4 verbietet das Überschreiben; Korrekturen
  entstehen als neue ADR mit `Supersedes`, und die schreibt nach §3.8 der **Architect**. — **Ausgang:**
  <eingetreten: Übergabe an den Architect, ADR-Kennung nachtragen | entfallen: der CR ändert die
  Menge nicht>
- **Die Weichen-Kommentare könnten den Rang-Zeiger als Beleg missverstehen.** Ein Kommentar, der
  auf [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) zeigt,
  ist ein Rang-Zeiger und zulässig; einer, der die Begründung **wiederholt**, ist die Quelle in
  keinem Rang, gegen die [`AGENTS.md`](../../../../AGENTS.md) §3.7 geschrieben ist. Die Grenze ist
  eine Urteilsfrage, kein Muster. — **Ausgang:** <entfallen: je Weiche ein Zeiger, keine zweite
  Fassung | weiter offen: → Beobachtung, sobald das Repo ein Register führt
  ([slice-137](../in-progress/slice-137-beobachtungs-register-bekommt-seinen-ort.md))>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

Erst nach Abschluss füllen.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `internal/emit/` (eigener Zuschnitt, eigene
Tests, eigene Ziel-Form — drei von drei Achsen) und `test/` (eigener Zuschnitt, eigene
Werkzeugkette — zwei von drei). Beide erfüllen die Schwelle ≥ 2; keine ist zu grob geschnitten.
`spec/` ist **nicht** berührt: der Slice liest die Datei, ändert sie aber nicht (§3).

**Vorgelagert — offene Beobachtungen sichten:** das Repo führt **kein** Beobachtungs-Register —
eine `observations.md` unter `docs/plan/planning/` existiert nicht, und ob sie entsteht, entscheidet
[slice-137](../in-progress/slice-137-beobachtungs-register-bekommt-seinen-ort.md). Keine Treffer, und der Grund ist
die fehlende Datei, nicht ein leeres Register.

Alle berührten Sub-Areas GF: `internal/emit/` und `test/` gehören zum Greenfield-Bestand; der Modus
steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md). Der Modus-Begründungsblock entfällt
damit nach dem *Umfang*-Absatz oben.

# Slice slice-agent-role-traegt-nicht-bekannt: Eine unbekannte Rolle trägt die Kennzeichnung *nicht bekannt*, und die Auswertung liest sie wie die leere

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** [welle-erfassungsschicht-im-ziel](../welle-erfassungsschicht-im-ziel.md) — nach
`slice-span-traegt-die-fassung-seiner-erfassungsregel`: der Wechsel `""` → *nicht bekannt* trägt dann
seine Fassung.

**Bezug:**
[`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung),
[`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans),
[`ADR-0078`](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) (Festlegung 4 Punkt 3),
[`MR-015`](../../../../harness/conventions.md#mr-015),
[`MR-036`](../../../../harness/conventions.md#mr-036),
[`MR-042`](../../../../harness/conventions.md#mr-042).

**Berührte Spec-Stellen:** `SPEC-010`, `SPEC-011`, `SPEC-012`, `SPEC-014`, `SPEC-043`, `SPEC-044`, `SPEC-055`, `SPEC-056`, `SPEC-087` (`spezifikation.md §5`).

**Verantwortlich:** pt9912

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** Ein **unbekannter** Wert trägt die Kennzeichnung *nicht bekannt* samt Quelle statt `""`
oder `[]`, und `make span-report` liest sie wie das leere Rollenfeld des Bestands — nach Lastenheft
0.25.1. Drei Stellen:

1. `agent_role` bei `general-purpose` und im Haupt-Kontext
   ([`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) *Rolle besetzt*,
   *Rolle wird abgeleitet*).
2. `branch` und `commit`, wenn die Ableitung aus dem git-Zustand nicht möglich ist
   ([`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans) *Zweig und
   Stand*; heute `SPEC-014`/`SPEC-056`: leer).
3. `slice`/`requirement` und die Entscheidungs-Achse bei unlesbarer Slice-Datei — heute liefert `references()` dann
   `[]`, das `SPEC-011`/`SPEC-012` als *keiner* lesen
   ([`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans) *Leer heißt
   keiner, unbekannt ist gekennzeichnet*). `[]` bleibt der Wert *keiner*.

Die Auswertung zählt den gekennzeichneten Lauf im Sammelposten, Spans vor und nach der Umstellung
landen im selben Posten (*Lesevorschrift*). `SPEC-043` verliert *(Abweichung 3)*; `SPEC-087` gilt
über die Cache-Zähler hinaus, und `SPEC-055` zählt die Fälle der Kennzeichnung vollständig auf.

```sh
grep -n 'sonst bleibt das Feld leer' spec/spezifikation.md
grep -n 'agent_role\\":\\"$erwartet' harness/tools/full-smoke.sh
```

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Change Request selbst.** *Anderer Vorgang:* ob [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) geändert wird, entscheidet der
  Auftraggeber ([`MR-015`](../../../../harness/conventions.md#mr-015),
  [`MR-036`](../../../../harness/conventions.md#mr-036)); der Anlass steht in der Closure-Notiz
  ([`MR-042`](../../../../harness/conventions.md#mr-042)). Entschieden in Lastenheft 0.25.0/0.25.1; dieser Slice setzt ihn um.
- **Der Cache-Status.** *Bestand bleibt stehen:* geliefert von
  `slice-span-pflichtfeld-traegt-nicht-bekannt` (`SPEC-024`, `SPEC-087`).

## 2. Definition of Done

- [x] **1 — Spezifikation:** `SPEC-087` gilt für die drei Stellen aus §1 (Quelle je benannt), `SPEC-043`
      trägt kein *(Abweichung 3)* mehr, `SPEC-010`/`011`/`012`/`014`/`044`/`055`/`056` sind nachgezogen — gemäß dem
      geänderten [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung).
- [x] **2 — Erfassung und Tests:** ein Span ohne erkennbare Rolle trägt die Kennzeichnung bei
      `agent_role`, einer ohne ableitbaren git-Zustand bei `branch`/`commit`, einer mit unlesbarer Slice-Datei bei den Korrelations-Listen; Feldliste (`span.FieldList`) und `make full-smoke` folgen. **Rot gesehen**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6): die Erfassung schreibt `""` — der benannte Test wird
      mit einer Meldung über genau dieses Feld rot; ein Fall in `test/mutations/` hält die Zusage.
- [x] **3 — Auswertung:** `make span-report` liest die Kennzeichnung wie `""`, keine Rolle
      *nicht bekannt* entsteht. **Rot gesehen:** die Auswertung prüft nur `""` — der Test mit einem
      Span, der die Kennzeichnung trägt, wird rot.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag und dem Anlass der Lastenheft-Änderung
      ([`MR-042`](../../../../harness/conventions.md#mr-042)).
- [x] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `spec/spezifikation.md` §5 | update | Liefer-Punkt 1 |
| `internal/span/emit.go` (Rollen-, git- und Bezugs-Ableitung), `internal/span/notknown.go`, `internal/span/fieldlist.go` | update | Liefer-Punkt 2 |
| `internal/span/*_test.go`, `harness/tools/full-smoke.sh` | update | Happy/Negative nach [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) |
| `internal/report/report.go` + Test | update | Liefer-Punkt 3 |
| `test/mutations/<NNN>-…sh` | neu | Mutations-Fälle für Liefer-Punkt 2 und 3 — Fälle 597 bis 602 |
| `internal/span/ruleversion.go`, `spec/spezifikation.md` §5 Fassungs-Tabelle | update | der Wechsel `""`/`[]` → Kennzeichnung ist ein Bedeutungswechsel nach `SPEC-089`; Fassung 4 (Cache-Status) lag in `v0.3.0`, dieser Wechsel kommt mit einem späteren Release → Fassung 5 (`SPEC-096`) |
| `test/mutations/593-…sh` | update | sein `sed`-Anker nannte Fassung 4 wörtlich und griff nach dem Hochzählen nicht mehr; er nimmt jetzt jede Fassung |
| `internal/emit/fieldlist_test.go`, `docs/user/rollen-laeufe.md` | update | der Grenz-Satz der Feldliste und das Handbuch nennen die Kennzeichnung statt des leeren Felds |

**Abweichungen vom Wortlaut in §1, gemessen am Stand:**

- `slice` bleibt bei unlesbarer Slice-Datei **bekannt** — der Name kommt aus dem Verzeichnis, nicht aus der Datei; die Kennzeichnung tragen `requirement` und `adr`. Alle drei tragen sie, wenn das Lifecycle-Verzeichnis selbst da und nicht lesbar ist.
- `branch` trägt die Kennzeichnung auch bei abgekoppeltem `HEAD` (der Zweig ist dort nicht ableitbar), `commit` allein bei einem Zweig ohne Commit.
- `spawned_role` bleibt unberührt: optional, bei unbekannter Rolle abwesend (`SPEC-083`); die Kennzeichnung gilt für Pflichtfelder.

## 4. Trigger

**Start** (`open` → `next`): der Auftraggeber hat den Change Request zu
[`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) entschieden — sichtbar als
Eintrag in `spec/lastenheft.md` §7 Historie — **eingetreten** (0.25.0, 0.25.1). Lehnt er ab, geht der Slice `open → done` mit
`Gegenstand: entfallen` und `SPEC-043` behält *(Abweichung 3)*.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: ein weiterer Leser von `agent_role` außer `internal/report` taucht auf.
- `in-progress` → `open`: der geänderte Wortlaut von [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) lässt die Draht-Form aus `SPEC-087`
  nicht zu — Übergabe an den Architect.

## 5. Closure-Trigger

1. `make gates` grün mit den Tests aus Liefer-Punkt 2 und 3; die Mutations-Fälle färben unter
   `make mutate` mit `MUTATE_CASES` ihren Wächter.
2. `grep -c '(Abweichung 3)' spec/spezifikation.md` → **0**, und `make full-smoke` EXIT 0.

## 6. Risiken und offene Punkte

- **Bedeutung eines Span-Felds wechselt ohne Fassungs-Angabe** — `agent_role` wechselt von `""` auf
  die Kennzeichnung; `span-feld-bedeutung-wechselt-ohne-fassungs-angabe` (Register) — Stand 3×, `geplant` auf `slice-span-traegt-die-fassung-seiner-erfassungsregel`, der vor diesem Slice läuft;
  ein weiterer Beleg ist Evidenz. — **Ausgang:** entfallen — der Wechsel trägt Fassung 5
  (`SPEC-096`, `CurrentRuleVersion = 5`; `make span-report` → `Fassung 5: 73 Zeile(n)`), Fall 593 hält die Konstante.
- **Die Kennzeichnung wird als Rolle gelesen** — ein Leser außer `internal/report` zählte
  *nicht bekannt* als eigene Rolle. — **Ausgang:** entfallen — außer `internal/report` liest kein Code
  `agent_role` (`grep -rn 'agent_role\|AgentRole'` außerhalb `internal/span`, Verifikation); dort binden
  `TestAggregiere_KennzeichnungIstKeineRolle` und Fall 602.

- **Der Slice wächst um zwei Ableitungen** (git-Zustand, Bezugs-Fehlerpfad; Lastenheft 0.25.1). Trägt er sie
  nicht in einer Review-Sitzung, Rückführung `in-progress` → `next`, Teilung nach Feld. — **Ausgang:** entfallen — ein Review-Lauf trug den ganzen Diff (0 HIGH, 0 MEDIUM).

## 7. Closure-Notiz

- **Anlass der Lastenheft-Änderung** ([`MR-042`](../../../../harness/conventions.md#mr-042)): Baseline
  `v6.14.0` (Welle 154, `modul-15` §Audit-Span-Schema) verlangt für ein Pflichtfeld, dessen Wert die Quelle
  nicht liefert, die Kennzeichnung *nicht bekannt* samt Quelle statt eines leeren Werts;
  [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) verlangte für die unbekannte
  Rolle das leere Feld, `SPEC-043` führte das als *(Abweichung 3)*
  ([`ADR-0078`](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 4 Punkt 3). 0.25.0
  (Nutzer-Entscheidung) nahm die Kennzeichnung für `agent_role` und die Lesart *`[]` heißt keiner* in
  [`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans) auf; 0.25.1 zog die
  Folgestellen nach, die 0.25.0 stehen ließ (*Zweig und Stand*, *Rolle besetzt*, *Lesevorschrift*).
- **Was hat funktioniert:** Kennzeichnung bei `agent_role`, `branch`/`commit` und den Korrelations-Listen,
  Fassung 5 (`SPEC-096`); `SPEC-087` nennt die Fälle abschließend, `grep -c '(Abweichung 3)' spec/spezifikation.md`
  → 0. `make mutate` (137, 593, 597–603) → `9 ok, 0 Befund(e)`, Fall 603 bindet allein; `make full-smoke` EXIT 0
  mit `nicht bekannt: agent_type` im Ziel. Review `docs/reviews/2026-10-08-agent-role-review.md` (0 HIGH,
  0 MEDIUM; F-1–F-3 in `79e0c4b9`), Verifikation `docs/reviews/2026-10-08-agent-role-verifikation.md`
  (DoD 1–3 bestätigt).
- **Was ging anders als geplant:** (1) `slice` bleibt bei unlesbarer Slice-Datei **bekannt** — der Name kommt
  aus dem Verzeichnis; gekennzeichnet sind `requirement` und `adr`, alle drei nur bei unlesbarem
  Lifecycle-Verzeichnis. §1 Punkt 3 nannte `slice` mit. (2) Bei abgekoppeltem `HEAD` trägt **nur** `branch`
  die Kennzeichnung, `commit` ist ableitbar (`SPEC-056` je Feld); §1 Punkt 2 und das Kriterium *Zweig und Stand*
  nennen *beide*, gemeint ist der Fall ohne mögliche Ableitung. Beides steht in §3, getragen von der
  Verifikation. (3) Fall 603 und `TestFeldliste_KennzeichnungNenntGenauDieFaelleDerSpezifikation` kamen aus
  Review-F-1 und stehen nicht in §3 (dort 597–602).
- **Grenzen:** (1) `make full-smoke` misst im Ziel nur `agent_role`; `branch`/`commit` und die Listen tragen
  allein die Unit-Tests mit den Fällen 598–601. (2) DoD 3 ist am echten Bestand nicht gegenprüfbar: der Bestand
  trägt keine Verbrauchs-Zähler (`make span-report` → `Keine Bilanz`), es entsteht keine Rollen-Zeile; getragen
  allein von `TestAggregiere_KennzeichnungIstKeineRolle`. (3) Die Lesbarkeits-Hälfte von `SPEC-098` (Zeile mit
  gekennzeichneter Liste bleibt lesbar) ist rot gesehen, aber ohne Fall in `test/mutations/`.
- **Steering-Loop-Eintrag:** neuer Sensor —
  `TestFeldliste_KennzeichnungNenntGenauDieFaelleDerSpezifikation` mit Fall 603 färbt rot, sobald die emittierte
  Feldliste die Felder mit Kennzeichnung nicht abschließend nennt; Fälle 597–602 halten Erfassung und Auswertung
  der Kennzeichnung ([`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung)).
- **Beobachtungs-Register (`../observations/`):** Beleg `evidence/slice-agent-role-traegt-nicht-bekannt.md` in
  `BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen` (Finding-Klassen Review F-1–F-3) und in
  `BEO-ALL/neuer-waechter-ohne-mutations-fall` (Grenze 3). Beide stehen über der Schwelle mit Ausgang
  `geplant`; kein Eintrag hebt sich auf 3× ([`ADR-0085`](../../adr/0085-slice-closure-mit-schwellen-uebertritt-ist-lese-schritt.md)).
  Grenzen 1 und 2: benannt, nicht gezählt — kein Eintrag trifft die Klasse.
- **Folge-Slices:** keine.
- **Risiken aus §6:** (1) entfallen, (2) entfallen, (3) entfallen — je Begründung in §6.
- **Drei Paarungen:** die Welle-Closure von `welle-erfassungsschicht-im-ziel` prüft sie erneut; die
  Slice-Closure fährt sie nach dem `git mv` selbst (Zeile unten).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo) — `internal/span/`,
`internal/report/` und `spec/` liegen in keiner engeren deklarierten Sub-Area.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet; Treffer
`span-feld-bedeutung-wechselt-ohne-fassungs-angabe` (3×, `geplant` auf den Fassungs-Slice), Zähler
`ls docs/plan/planning/observations/BEO-ALL/span-feld-bedeutung-wechselt-ohne-fassungs-angabe/evidence/*.md | wc -l`
(§6). Kein weiterer Treffer zum Erfassungs-Schema.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

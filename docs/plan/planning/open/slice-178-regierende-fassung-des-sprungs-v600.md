# Slice slice-178: Die regierende Fassung des Sprungs `v5.18.0` → `v6.0.0` wird entschieden

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-15](../welle-15-re-baseline.md) — **Mitglied**, und die Präzedenz ist derselbe
Gegenstand eine Runde früher: [slice-163](../done/slice-163-regierende-fassung-des-sprungs.md) trug
diese Frage für den Sprung auf `v5.18.0` als Mitglied von
[welle-14](../done/welle-14-re-baseline.md) und löste deren offene Übergabe aus §5 ein. Der Slice
löst hier Übergabe 1 aus [welle-15](../welle-15-re-baseline.md) §5. Der andere Kandidat,
[slice-172](../done/slice-172-adr-archivierung-als-unterkommando.md), beantwortet die Frage nicht:
Er lief wellenlos, weil zum Zeitpunkt seines Schnitts **keine Welle offen war** —
`git merge-base --is-ancestor d0ad524 ea2dc71 && echo 'welle-14 war vor dem Schnitt geschlossen'`
(die zwei Commits sind der `welle-14`-Self-Close und der Schnitt-Commit).

**Bezug:**
[`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (Festlegung 1 gilt
**nur** für `v5.12.0` → `v5.18.0`; ihr erster Re-Evaluierungs-Trigger verlangt für diesen Sprung
eine neue, zweistufige Messung),
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (Festlegung 3 stellt das
Kriterium, das die Messung anwendet),
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) (die Wahl der normativen Quelle
ist eine Architektur-Frage),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tag ist die
Reproduzierbarkeits-Klammer, und die Wahl entscheidet, welcher der beiden das Verfahren stellt).

**Berührte Spec-Stellen:** `—`. Der Slice entscheidet eine Prozess-Frage; er schreibt keine
Spec-Stelle.

**Verantwortlich:** Architect

**Autor:** Planner. **Datum:** 2026-09-04.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Welche Regelwerks-Fassung die Migrations-Prozedur des Sprungs `v5.18.0` → `v6.0.0` stellt, steht
als angenommene Entscheidung auf Rang 4 der Source Precedence — bevor ein Durchgang dieser Welle
ein Konformitäts-Urteil fällt.**

Der Anlass ist gemessen und steht in der zitierten Entscheidung selbst:
[`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 1 ist
ausdrücklich auf `v5.12.0` → `v5.18.0` geschlossen, und ihr erster Re-Evaluierungs-Trigger sagt für
den nächsten Sprung *„misst neu — und zwar beides"*. Die zweistufige Messung liefert
[slice-176](../in-progress/slice-176-inventur-vor-dem-schnitt-v600.md) DoD 3; dieser Slice **wählt** auf
ihr und misst nicht noch einmal.

**Eine neue, eigenständige ADR — kein `Supersedes`.** Eine Entscheidung über diesen Sprung ändert
an [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) nichts: Ihre
Festlegung 1 bleibt für den vorigen Sprung wahr, ihre Festlegung 2 gilt unverändert. Das ist
dieselbe Bauart, mit der jene ADR
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) **anwendet**, statt sie zu
ersetzen.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Die ADR liegt und entscheidet die regierende Fassung dieses Sprungs**, mit dem Grund, der
      *hier* trägt, statt dem von
      [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 1
      abgeschriebenen. Sie zitiert das Ergebnis beider Mess-Stufen aus
      [slice-176](../in-progress/slice-176-inventur-vor-dem-schnitt-v600.md) §9 als Zeiger, statt es zu
      wiederholen. `Status` steht in ihr; bei `Proposed` steht der Acceptance-Trigger daneben
      (Präzedenz [slice-171](../open/slice-171-adr-0031-acceptance-trigger.md)).
- [ ] **Die Abgrenzung ist ausgesprochen:** kein `Supersedes` auf
      [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) und keine
      allgemeine Regel *„es regiert stets die Ziel-Fassung"* — die bleibt verworfen
      ([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) §Verglichene Alternativen,
      Option C), und der übernächste Sprung misst wieder.
- [ ] `make gates` grün.
- [ ] Doku-Update: der ADR-Index ([`docs/plan/adr/README.md`](../../adr/README.md)) trägt die neue
      Zeile ([`AGENTS.md`](../../../../AGENTS.md) §5); [welle-15](../welle-15-re-baseline.md) §5
      führt Übergabe 1 als erledigt. Ein öffentlicher Vertrag ist nicht berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/adr/` | neu | die Entscheidung, per `cp` aus der vendored ADR-Vorlage |
| [`docs/plan/adr/README.md`](../../adr/README.md) | update | der Index wächst mit der ADR |
| [welle-15](../welle-15-re-baseline.md) §5 | update | Übergabe 1 hat einen Ausgang |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-176](../in-progress/slice-176-inventur-vor-dem-schnitt-v600.md)
liegt in `done/`. Der Grund ist tragend, nicht ordnend: Die Wahl steht auf der zweistufigen Messung
jenes Slice, und der Katalog daneben sagt, welche Positionen des Sprungs überhaupt ein
Konformitäts-Urteil verlangen.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Messung eine dritte Stufe
  verlangt — etwa weil die Ziel-Fassung die Prozedur an einen anderen Abschnitt verlegt und der
  Vergleich erst eine Zuordnung braucht. Dann trennt der Schnitt Zuordnung und Wahl.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Messung ergibt, dass die Ziel-Fassung
  die Meta-Frage selbst beantwortet (dritter Re-Evaluierungs-Trigger von
  [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)). Dann ist nicht
  zu **wählen**, sondern eine Abweichung zu deklarieren — anderer Gegenstand, anderer Slice.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; die ADR trägt `Status:` und, falls `Proposed`, ihren Acceptance-Trigger;
Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die erste Mess-Stufe kommt byte-gleich heraus und die Wahl wird als *egal* gelesen**
  (`BEO-019` im [Register](../observations.md)). Der Abschnitt delegiert in andere Dateien, und
  deren Delta trägt die Wirkung; die zweite Stufe ist deshalb Pflicht, nicht Zugabe. —
  **Ausgang:** <…>
- **Die ADR schreibt eine Regel statt einer Entscheidung.** Eine allgemeine Fassung bände
  Prozeduren, deren Wortlaut niemand kennt; sie ist zweimal verworfen und bleibt es. —
  **Ausgang:** <…>
- **Die ADR steht auf `Proposed` und bindet den Durchgang nicht.** Zwei Slice-Kennungen in `open/`
  tragen heute genau diese Restpflicht für ältere ADRs
  ([slice-171](../open/slice-171-adr-0031-acceptance-trigger.md),
  [slice-152](../open/slice-152-adr-0029-acceptance-trigger.md)); eine dritte wäre ein Muster.
  Der Acceptance-Trigger gehört darum in die ADR selbst. — **Ausgang:** <…>

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
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations.md`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** dieses Repo führt Wellen-Betrieb — sie prüft die Closure von
  [welle-15](../welle-15-re-baseline.md).

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die einzige Sub-Area, die
die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) für
Norm-Artefakte führt.

**Vorgelagert — offene Beobachtungen sichten:** Das [Register](../observations.md) ist vollständig
durchgegangen. **Jede** Zeile trägt `*` (gesamtes Repo) — die Spalte unterscheidet in diesem Repo
nichts (`BEO-004`). Drei Zeilen berühren diesen Slice mit ihrem Zähler-Stand, keine erreicht mit
ihm 3×:

- `BEO-019` (1×) — *Byte-Gleichheit an einem Abschnitt wird als Aussage über die Regel gelesen*.
  Steht als Risiko in §6 und bindet die Form der zitierten Messung.
- `BEO-027` (1×) — *ein lebendes Plan-Artefakt fasst eine Entscheidung stärker zusammen als die
  Quelle*. Bindet diesen Plan: er zitiert
  [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md), statt sie zu
  referieren.
- `BEO-016` (1×) — *Slice-Pläne tragen ein Vielfaches der nötigen Zeilenzahl*. Bindet diesen Plan
  selbst; er ist deshalb knapp gehalten.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.

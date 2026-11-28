# Slice slice-altbestand-stubs-voll-v1: Der Umzugs-Stub je referenziertem Umzug (Implementation [`ADR-0112`](../../adr/0112-umzugs-stub-traegt-die-referenzen-die-der-nachzug-nicht-erreicht.md))

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle ([`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst):
der Baseline-Test ist das *Mehr* — eine beobachtbare Closure-Bedingung, die
mehr beobachtet als die DoD dieses Slice; es gibt keine, der Closure-Trigger
unten wäre die Abschrift der eigenen DoD). Wellenlose Arbeit erscheint nicht
in der Roadmap (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine
Welle braucht).

**Bezug:**
[`ADR-0112`](../../adr/0112-umzugs-stub-traegt-die-referenzen-die-der-nachzug-nicht-erreicht.md)
(`Accepted`, `6b81fd0c` — die bindende Fassung: der Umzugs-Stub an der alten
Adresse — Festlegung 1 mit dem **Suchraum-Differenzial** als Kriterium, die
Stub-Form mit Umzugs-Zeiger — Festlegung 2, die Vorschau-Funde-Zeile —
Festlegung 3, was nicht passiert — Festlegung 4),
[`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
(die Formel „ein eingehender Verweis löst weiter auf" über alle Klassen —
Festlegung 1; die Report-Stub-Vorlage als Form-Präzedenz — Festlegung 2),
[`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
(Festlegung 1 erlaubt den Nachzug in Zeitdokumente, Festlegung 2 nimmt
`docs/plan/adr` daraus aus — unverändert),
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md)
(Abnahme-Kriterium 1 trägt die `[haenger]`-Sperre, Abnahme-Kriterium 2 die
explizite Staging-Aufzählung),
[`MR-072`](../../../../harness/conventions.md#mr-072--ein-review-report-bekommt-beim-archivieren-einen-stub-entgegen-dem-wortlaut-der-ziel-form)
(die Form, die den Report-Anteil der `[haenger]`-Sperre auffängt — der
Umzugs-Stub ist die fünfte Klasse derselben Mechanik),
[`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/
[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
(Anlage-Disziplin der Mutations-Fälle),
[`AGENTS.md`](../../../../AGENTS.md) §3.4 (kein Nachzug in die `Accepted`-ADR-Klasse),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(die zwei [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md)-`ignore-refs`-Paare bleiben; kein neues Ventil).

**Berührte Spec-Stellen:** `—` — die Entscheidung trägt die Prozess-ADR
([`ADR-0112`](../../adr/0112-umzugs-stub-traegt-die-referenzen-die-der-nachzug-nicht-erreicht.md):
Archivierungs-Operation, keine Anforderung). Der Verweis zeigt **aufwärts**:
Die Spec nennt diesen Slice nie.

**Verantwortlich:** pt9912

**Autor:** pt9912 (Rolle Planner, je [`ADR-0112`](../../adr/0112-umzugs-stub-traegt-die-referenzen-die-der-nachzug-nicht-erreicht.md)
Architektur-Skizze, Architektur-Zug `6b81fd0c`). **Datum:** 2026-11-28.

---

## 1. Ziel und Abgrenzung

**Ziel:** die Implementation von [`ADR-0112`](../../adr/0112-umzugs-stub-traegt-die-referenzen-die-der-nachzug-nicht-erreicht.md)
Festlegungen 1–3 — der Altbestand-Lauf schreibt je **referenziertem** Umzug
(ein Basename aus `b.Verschwindend()`, der in einer Datei aus
`Suchraum(…) \ SuchraumNachzug(…)` steht) einen Umzugs-Stub an der flachen
Pfad-Adresse `done/<base>`, statt die Adresse leer fallen zu lassen; das
Differenzial-Kriterium ist mechanisch an der Containment-Form des
Haenger-Wächters — entsteht ein vierter ausgenommener Baum, trägt das
Kriterium ihn ohne neue Entscheidung.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- *(Kein Nachzug.)* Der Nachzug in die ADR-Klasse entfällt — [`AGENTS.md`](../../../../AGENTS.md)
  §3.4 verboten, [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
  Festlegung 2 steht und trägt ([`ADR-0112`](../../adr/0112-umzugs-stub-traegt-die-referenzen-die-der-nachzug-nicht-erreicht.md)
  Festlegung 4); genau deshalb trägt der Stub die Referenzen.
- *(Benannt, nicht geschlossen — Festlegung 4.)* Die drei Gegenformen
  (Zustandssatz neben der Adresse, Operand im Mess-Kommando,
  Abschnitts-Anker auf einen gekürzten Stub) gelten für den Umzugs-Stub
  unverändert — kein Sensor; die zwei [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md)-`ignore-refs`-Paare
  bleiben (ihr Rückbau wäre eine Schärfung ohne eigenen Träger, ihre
  Restbreite fällt mit den Stubs, nicht durch sie); kein `Supersedes` einer
  `Accepted`-ADR, kein emittiertes Ziel.
- *(Es wäre ein anderer Vorgang.)* Die Report-Ziel-Klassen der
  Auftrags-Tabelle bekommen keinen eigenen Stub-Apparat — gemessen gelöst
  ([`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
  Implementations-Slice, `slice-report-stub-am-unveraenderten-pfad`); der
  Umzugs-Stub greift allein über das Differenzial-Kriterium, nicht über eine
  Klassen-Liste der Quellen.

## 2. Definition of Done

- [ ] **Liefer-Punkt 1:** das **Kriterium und der Schreiber-Zug** in
      [`internal/archive/anwenden.go`](../../../../internal/archive/anwenden.go)
      — das Suchraum-Differenzial (Basename aus `b.Verschindend()` ↔ Referenz
      in `Suchraum(…) \ SuchraumNachzug(…)`), der Umzugs-Stub-Write
      **vor dem Nachziehen** je referenziertem Umzug an `done/<base>`, die
      `FormOK`-**Umzugsvariante** (Zuzugs-Zeiger statt
      `> **ARCHIVIERT**`-Zip-Zeiger — ein Stub mit Umzugs-Zeiger und vollem
      Text wäre der Umzug, der nicht stattfand) und die `ZuStagen`-Erweiterung
      (die Staging-Aufzählung führt die neuen Pfade explizit,
      [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md)
      Abnahme-Kriterium 2); Wächter je Fitness-Tafel
      ([`ADR-0112`](../../adr/0112-umzugs-stub-traegt-die-referenzen-die-der-nachzug-nicht-erreicht.md)):
      Go-Test — ein Umzug mit ausgenommen-Baum-Referenz hinterlässt den Stub
      an der flachen Adresse, ohne Referenz keinen, `ZuStagen` führt ihn
      (`make test`); die Mutations-Fälle je
      [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
      — fällt das Differenzial still weg oder die `FormOK`-Variante rückt,
      färbt der Wächter rot.
- [ ] **Liefer-Punkt 2:** die **repo-eigene Umzugs-Stub-Vorlage**
      `docs/plan/planning/archive-stub-umzug.template.md` <!-- d-check:ignore (Platzhalter: die Vorlage entsteht im Implementer-Zug, ADR-0112 Festlegung 2) --> (Name je
      [`ADR-0112`](../../adr/0112-umzugs-stub-traegt-die-referenzen-die-der-nachzug-nicht-erreicht.md)
      Festlegung 2) als Nachbar der Report-Vorlage — Identität (H1), der
      **Umzugs-Zeiger** auf die neue Arbeitsbaum-Adresse
      (`done/<wave-id>/…` bzw. `done/altbestand/…`), der Zustand
      (`Archiviert mit: <der Schüssel>`); kein `##`-Glied — der Volltext
      liegt byte-genau an der neuen Adresse (nicht nur im Zip), der Stub
      ist die Adresse, die ihn liest.
- [ ] **Liefer-Punkt 3:** die **Vorschau-Funde-Zeile je verweisender
      ADR-Datei** in
      [`internal/archive/vorschau.go`](../../../../internal/archive/vorschau.go)
      — die referenzierten Umzugs-Basenamen gehen als Haenger-Ziele an die
      Vorschau, die Funde-Zeile nennt je verweisender ADR-Datei die umzogene
      Ziel-Datei (ohne ausgenommene-Baum-Referenz ist die Zeile leer —
      ausgeschrieben je Fitness-Tafel); die `[haenger]`-Sperre bleibt auf
      ihrer Rolle: leer für diese Klasse, weil der Lauf sie selbst trägt,
      fail-closed, weil die Funde-Zeile die Stub-Menge als Pflicht vor den
      zwei Commits stellt. Die Adress-Abdeckung
      (`make docs-check-host`) hält: ein ADR-Verweis auf einen umgezogenen
      Slice löst nach dem Lauf an der alten Adresse weiter auf.

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; Gate-Läufe und die Closure-Pflichten
zählen nicht mit.

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben —
      `evidence/`-Datei ergänzen, wo eine Beobachtung anfiel; keine
      Beobachtung anfallen ist ebenfalls eine Antwort und wird in §7
      notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind hier geprüft
      — Repo ohne Wellen-Betrieb, nach dem `git mv`.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/archive/anwenden.go`](../../../../internal/archive/anwenden.go) | update | Differenzial-Kriterium + Umzugs-Stub-Write **vor dem Nachziehen** + `FormOK`-Umzugsvariante + `ZuStagen`-Erweiterung — LP 1 |
| [`internal/archive/form.go`](../../../../internal/archive/) (Zustands-Form, Name beim Implementer) | update | die `FormOK`-Umzugsvariante (Zuzugs-Zeiger statt Zip-Zeiger) — LP 1 |
| `docs/plan/planning/archive-stub-umzug.template.md` <!-- d-check:ignore (Platzhalter: die Vorlage entsteht im Implementer-Zug, ADR-0112 Festlegung 2) --> | neu | die repo-eigene Umzugs-Stub-Vorlage, Form je Festlegung 2 — LP 2 |
| [`internal/archive/vorschau.go`](../../../../internal/archive/vorschau.go) | update | Haenger-Ziele je referenziertem Umzug + Funde-Zeile je verweisender ADR-Datei; Sperren-Form unverändert — LP 3 |
| `internal/archive/` (Tests), `test/mutations/<neue Fälle>` | update/neu | Go-Tests je Fitness-Tafel + Mutations-Form als Anlage je [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit) — je LP |

## 4. Trigger

**Start** (`next` → `in-progress`): [`ADR-0112`](../../adr/0112-umzugs-stub-traegt-die-referenzen-die-der-nachzug-nicht-erreicht.md)
ist `Accepted` (beobachtbar an der Status-Zeile; Architektur-Zug `6b81fd0c`).
Ein weiterer Architektur-Zug braucht es davor nicht — die Fassung trägt die
ADR selbst (Festlegungen 1–4).

**Rückführungen — vorab benennen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): gerät der Nachzug
  in die ADR-Klasse, ein neues `ignore-refs`-Paar oder ein Stub-Apparat für
  die Report-Ziel-Klassen in den Umfang — alles drei ist in §1
  ausdrücklich ausgeschlossen.
- `in-progress` → `open` (blockiert — Carveout?): das Differenzial-Kriterium
  braucht eine zweite Suchraum-Semantik (etwa ein zweiter ausgenommener Baum
  ohne Containment-Form), oder [`ADR-0112`](../../adr/0112-umzugs-stub-traegt-die-referenzen-die-der-nachzug-nicht-erreicht.md)
  Festlegung 3 trägt die Sperren-Rolle nicht an der Vorschau-Form — die
  Frage geht an den Architect, bevor der schreibende Lauf umgebaut wird.

## 5. Closure-Trigger

DoD (§2) vollständig, und die Fitness-Zeilen von
[`ADR-0112`](../../adr/0112-umzugs-stub-traegt-die-referenzen-die-der-nachzug-nicht-erreicht.md)
§Fitness Function sind gezeigt: Stub an der flachen Adresse je
ausgenommen-Baum-Referenz (und ohne Referenz keinen), der ADR-Verweis auf
einen umgezogenen Slice löst nach dem Lauf an der alten Adresse weiter auf,
die Funde-Zeile nennt je verweisende ADR-Datei das umzogene Ziel (und ist
ohne Referenz leer), die drei Mutations-Fälle färben je benanntem Grund rot,
`make gates` grün, Review-Report unter `docs/reviews/`. Zusätzlich:
Closure-Notiz mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- **Die drei Gegenformen am Umzugs-Stub** (Zustandssatz neben der Adresse,
  Operand im Mess-Kommando, Abschnitts-Anker auf einen gekürzten Stub) —
  kein Sensor, Träger bleibt der Lauf, der schreibt
  ([`ADR-0112`](../../adr/0112-umzugs-stub-traegt-die-referenzen-die-der-nachzug-nicht-erreicht.md)
  Festlegung 4). — **Ausgang (vorgesehen):** weiter offen · benannt, nicht
  geschlossen; Re-Evaluierungs-Trigger der ADR greifen.
- **Der Stub-Overhead wächst mit neuen ADR-Verweisen auf Slices** — die
  Klasse ist messbar (Funde-Zeile), der Preis klein
  ([`ADR-0112`](../../adr/0112-umzugs-stub-traegt-die-referenzen-die-der-nachzug-nicht-erreicht.md)
  §Verglichene Alternativen E Contra). — **Ausgang (vorgesehen):** entfallen
  mit Grund — die Vorschau-Funde-Zeile macht die Menge sichtbar je Lauf;
  wächst die Zahl, ist das der sichtbare Ort, kein Still-Leiden.
- **Die Restbreite der zwei [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md)-`ignore-refs`-Paare** fällt mit den
  Stubs, nicht durch sie — ihr Rückbau ist eine eigene Schärfungs-Entscheidung,
  nicht Teil dieses Slices. — **Ausgang (vorgesehen):** weiter offen ·
  benannt; der Rückbau braucht eine eigene ADR je
  [`AGENTS.md`](../../../../AGENTS.md) §3.5.

## 7. Closure-Notiz

<!-- BEDIENHINWEIS — keine Norm; faellt beim Kopieren weg (README.md
§Verwendung, Schritt 5) und darf deshalb nichts Tragendes halten. Reihenfolge:
diese Sektion vor dem `git mv` nach done/ fuellen — einzige Ausnahme ist das
letzte DoD-Item in §2 (die Paarungen suchen in `done/`, also nach dem `git mv`).
Im Repo ohne Wellen-Betrieb braucht die Closure dadurch drei Commits: Inhalt,
`git mv`, Haekchen — das folgt aus der Hard Rule, es widerspricht ihr nicht. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln. Ging
der Gegenstand an einen anderen Slice oder entfiel er, trägt diese Sektion die
Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko aus §6 seinen
Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die zwei vorgelagerten
Schritte und die vier Pflichtkriterien (Konventionen-Dichte · Phase-Reife ·
Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und nicht mehr.
Der Abschnitt selbst entfällt nie; bedingt ist allein der
Modus-Begründungsblock am Ende.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `*` (gesamtes Repo,
Kürzel `ALL`, Modus-Deklaration
[`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area — die ADR-Index-Zelle und die Planning-Bäume
liegen in keinem Kürzel-Baum) und `harness/tools/` (`TOOLS`) — die Schwelle
≥ 2 von 3 Achsen ist je erfüllt (Strukturregeln über den Adaptions-Block,
Phase-Reife Phase 5).

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen
(`docs/plan/planning/observations/BEO-ALL/`). Die Herkunft dieser Klasse ist
[`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/state.md)
—— verkörpert ([`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
Festlegung 3); dieser Slice arbeitet an der Verleger-Form, bei Closure
`evidence/slice-altbestand-stubs-voll-v1.md` ergänzen. Keine Treffer unter
der Schwelle an der berührten Ebene.

**Modus:** alle berührten Sub-Areas GF — der Modus-Begründungsblock entfällt.

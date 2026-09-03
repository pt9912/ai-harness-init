# Slice slice-165: Die stummen `v5.12.0`-Nennungen bekommen ihren Ausgang

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-14](../welle-14-re-baseline.md).

**Bezug:** [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
(die Setzung, die diesen Durchgang vorschreibt),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(die Kopplung Zahl ↔ Kommando, die der Sprung zerreißt),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** Planner (pt9912) — die Restmenge sind lebende Plan- und Norm-Artefakte, und
der Ausgang je Treffer ist eine Sortier-Entscheidung nach
[`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum),
keine Implementation. Das Feld weicht damit von der Default-Besetzung ab, die
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine nennt.

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Jede stumme Nennung des abgelösten Tags in einem lebenden repo-eigenen Artefakt trägt genau
einen der drei Ausgänge aus
[`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
— nachgemessen · Tree-Operand · entfallen.**

Stumm heißt: kein Markdown-Link, also kein `target-missing`, also kein Gate. Der Tausch auf
`v5.18.0` ([slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md)) hat den
gate-sichtbaren Teil erledigt und den stummen unberührt gelassen — dort ist die Adresse meist
Operand eines Kommandos, dessen Ergebnis im selben Satz zitiert wird, und ein Pfad-`sed` machte aus
einem lauten Fehler einen stummen.

**Der Bestand ist gemessen, nicht geschätzt** — beim Lauf neu zu erheben, die Zahl wandert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

```sh
git grep -n 'v5\.12\.0' -- ':!.harness/baseline' ':!docs/reviews' \
  ':!docs/plan/planning/done' ':!docs/plan/adr' | grep -vc ']('   # vor diesem Durchgang: 152
```

**Alle Stände dieses Abschnitts sind die *vor* dem Durchgang** — er verkleinert seine eigene
Bezugsmenge, und ein Stand danach beschriebe das Ergebnis, nicht die Aufgabe. Was übrig bleibt und
warum, steht in §7.

**Zwei Teilmengen liegen ausdrücklich außerhalb:** der **Adaptions-Speicher** — die Index-Datei
[`harness/conventions.md`](../../../../harness/conventions.md) **und** das Eintrags-Verzeichnis
`harness/conventions/` daneben ([`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form))
— gehört dem Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8) und wird von
[slice-157](../done/slice-157-adaptions-durchgang-v5180.md) getragen; seine Größe misst dieselbe
Zählung, auf beide Pfade eingeschränkt:

```sh
git grep -n 'v5\.12\.0' -- harness/conventions.md harness/conventions/ | grep -vc ']('   # 85
```

Und die **eingefrorenen** ADRs bleiben
unangetastet: [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
§Geltungsbereich schließt `docs/plan/adr/` selbst aus.

**Die Restmenge dieses Slice ist damit die Differenz** — dasselbe Kommando mit beiden zusätzlichen
Ausschlüssen (`':!harness/conventions.md' ':!harness/conventions/'`): vor diesem Durchgang **55**.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **Jeder Treffer der Restmenge trägt einen der drei Ausgänge**, je Treffer entschieden und
      am Fundort begründet, wo der Ausgang *Tree-Operand* oder *entfallen* ist. Ein pauschales
      „alle gezogen" erfüllt den Punkt nicht. **Vier Treffer tragen ihren Ausgang, aber nicht den
      Schreib-Akt** — sie liegen in [`AGENTS.md`](../../../../AGENTS.md) §3.7 und gehen als
      [slice-169](../in-progress/slice-169-agents-37-messstaende-gegen-v5180.md) an den Architect (§7).
- [x] **Keine Zahl ist mitgewandert:** wo der Ausgang *nachgemessen* lautet, ist das Kommando
      gegen den neuen Baum gefahren und die **Folgerung** gezogen, nicht die Ziffer gerundet.
      Belegt an mindestens einem Treffer, dessen Ergebnis sich bewegt hat — findet der Lauf
      keinen, ist **das** der Befund und steht in §7.
- [x] `make gates` grün.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt — [`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md) auf **1.12**: die Abschluss-Zeile nennt den neuen Baseline-Stand.
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
| lebende Plan- und Welle-Dateien unter `docs/plan/planning/` | update | die Mehrzahl der Treffer |
| [`AGENTS.md`](../../../../AGENTS.md) | update | Mess-Stände in §3.7 — Hard Rule, also Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8), eigener Commit |
| `internal/emit/templates.go`, `internal/emit/templates_test.go` | update | Kommentare mit einer Aussage über den vendored Satz ([`AGENTS.md`](../../../../AGENTS.md) §3.7) |
| [`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md), [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md), [`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md) | update | je eine Handvoll Treffer, verschiedene Ausgänge |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md)
liegt in `done/` — vorher gibt es keinen neuen Baum, gegen den nachgemessen würde.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Restmenge nicht in einer
  Review-Sitzung prüfbar ist — dann wird nach Artefakt-Klasse geteilt (Plan-Dateien / Go-Kommentare
  / Anweisungssätze).
- `in-progress` → `open` (blockiert — Carveout?): wenn ein Treffer eine Aussage trägt, deren
  Nachmessung eine Entscheidung verlangt, die einer anderen Rolle gehört.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; die Restmenge ist mit dem Kommando aus §1 neu erhoben und je Treffer verbucht;
Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Durchgang zieht den Tag und lässt die Zahl stehen** — genau der Fehler, gegen den
  [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
  steht, und kein Gate sieht ihn. — **Ausgang:** **entfallen** — jede der 37 nachgemessenen
  Stellen trägt im Diff neben der geänderten Pfadzeile eine neu gefahrene oder ausdrücklich als
  unverändert bestätigte Ergebniszeile; wo das Ergebnis sprang, ist die Folgerung gezogen (§7).
- **Ein Teil der Treffer gehört dem Architect** ([`AGENTS.md`](../../../../AGENTS.md) §3.7/§3.8),
  und ein Planner- oder Implementer-Lauf schreibt sie im Vorbeigehen mit. — **Ausgang:**
  **entfallen** — die vier §3.7-Treffer sind unberührt und als
  [slice-169](../in-progress/slice-169-agents-37-messstaende-gegen-v5180.md) übergeben; berührt hat dieser
  Lauf allein §1 derselben Datei, den §3.8 nicht bindet.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Die Restmenge, erhoben und je Treffer verbucht.** Vor dem Durchgang **55**, nach den zwei
Inhalts-Commits und **vor** dem `git mv` **18** (dasselbe Kommando aus §1 mit den zwei
zusätzlichen Ausschlüssen). Der `git mv` tauscht anschließend zwei Glieder derselben Summe: der
Titel dieser Datei verlässt die Menge — `done/` steht im Ausschluss —, und die Zitat-Nennung in
[slice-169](../in-progress/slice-169-agents-37-messstaende-gegen-v5180.md) tritt ein. Die Verteilung der
drei Ausgänge:

| Ausgang | Zahl | Fundorte |
|---|---|---|
| **nachgemessen** — Pfad gezogen, Kommando neu gefahren | 37 | `close-welle.md` (2) · `reviewer.md` Kopf (1) · `slice-090` (1) · `slice-091` (3) · `slice-101` (2) · `slice-112` (2) · `slice-114` (8) · `slice-134` (4) · `slice-140` (2) · `slice-151` (1) · `welle-09` (1) · `welle-11` (7) · `benutzerhandbuch.md` §Beispielablauf (1) · `spezifikation.md` §Aufnahme-Regel (1) · `internal/emit/templates.go` (1) |
| **Tree-Operand** — spricht über die Vor-Tausch-Seite, bleibt stehen | 11 | `reviewer.md` Versions-Log 1.5.0 (2) · `CO-005` (1, datierter Gate-Lauf) · diese Datei, Titel (1) · [welle-14](../welle-14-re-baseline.md) (3: Start-Trigger, Sprung-Ausgang, Versions-Range) · `benutzerhandbuch.md` Historie 1.11 (1) · `templates.go`/`templates_test.go` Herkunfts-Marken (2) · `spezifikation.md` Historie 2026-08-28 (1) |
| **entfallen** — Gegenstand verloren, mit Begründung aufgehoben | 0 als Tag-Nennung | Der Ausgang traf **eine Aussage**, nicht eine Nennung: [slice-114](../open/slice-114-jede-aussage-hat-einen-abschnitt.md) §1 las *„`## Leseordnung` fehlt"*, der Abschnitt steht in der Datei. Ihre Nennung selbst lief unter *nachgemessen* — die Adresse blieb gebraucht |

**Die vier verbleibenden Treffer sind gemessen, aber nicht geschrieben:** sie liegen in
[`AGENTS.md`](../../../../AGENTS.md) §3.7, und §3 dieser Datei ist Hard Rule und damit
Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Ihr Ausgang **nachgemessen** steht fest —
alle drei Kommandos geben gegen `v5.18.0` unverändert **1** aus —, den Schreib-Akt trägt
[slice-169](../in-progress/slice-169-agents-37-messstaende-gegen-v5180.md).

**Closure-Kriterien (beobachtet, nicht behauptet):**

1. **Die Restmenge ist neu erhoben und je Treffer verbucht** — Tabelle oben: 37 nachgemessen +
   11 Tree-Operand + 4 Übergabe = **55**. Der Reststand **18** ist diese 11 + 4 plus **3** neu
   geschriebene Tree-Operanden: das Versions-Log 1.6.0 von
   [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) nennt den Re-Pin-Sprung
   und führt seine zwei `git show`-Belege am abgelösten Tag.
2. **`make gates` grün** nach dem Commit dieser Notiz; der Stop-Hook-Stempel deckt den Arbeitsbaum.

- **Was hat funktioniert:** Die Trennung von *Ausgang bestimmen* und *Ausgang schreiben*. Für die
  vier `AGENTS.md`-Treffer war der Ausgang in diesem Lauf entscheidbar und die Messung billig; nur
  der Schreib-Akt gehört einer anderen Rolle. Das Übergabe-Artefakt trägt die Messung mit, statt
  sie im Architect-Lauf zu wiederholen.
- **Was ging anders als geplant:** §3 dieses Plans nennt `internal/emit/templates*.go`,
  `AGENTS.md`, die Plan-Dateien und drei Einzelartefakte — `spec/spezifikation.md` steht dort
  nicht, trägt aber zwei Treffer. Die Kandidaten-Tabelle war keine Ausschluss-Liste; die
  Bezugsmenge ist das Kommando aus §1, und das trifft Rang 2 mit. Und die Ausschluss-Angabe *„88
  Treffer in `harness/conventions.md`"* zeigte auf die Einzeldatei-Form des Adaptions-Blocks, den
  [`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)
  seither in ein Verzeichnis überführt hat — die Grenze steht jetzt auf beiden Pfaden.
- **Steering-Loop-Eintrag: eine benannte Spec-Lücke** —
  *[`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
  bindet die **Baum**-Hälfte einer
  Präsens-Aussage; der repo-eigene Operand daneben, der im selben Satz zitiert wird, hat beim
  Sprung keinen Ausgang*. Gemessen: die Zahlen, die dieser Durchgang bewegen musste, standen
  überwiegend auf der repo-eigenen Seite (`harness/README.md` **16 161** → **19 116** Zeichen, ihre
  Abschnittszahl **6** → **7**, der Adaptions-Speicher **148 721** → **339 546**); auf der
  Baum-Seite bewegte sich zweierlei (die Konventions-Vorlage des vendored Satzes wuchs von
  **8 785** auf **9 658** Zeichen, und zwei wiederkehrende Vorlagen kamen hinzu). Kein Zielort — die Lücke ist **benannt**, nicht
  verkörpert: sie liegt als sechster Beleg an [`BEO-009`](../observations.md), und ihr Ausgang
  hängt an dem dort geplanten [slice-153](../open/slice-153-wellen-commands-nennen-die-roadmap-abschnitte.md).
- **Beobachtungs-Register (`../observations.md`):** keine neue Kennung —
  [`BEO-009`](../observations.md) von 5× auf **6×** erhöht, Beleg `slice-165`. Die Klasse ist
  dieselbe: ein Vorgang korrigiert die Ableitung (den Pfad) und lässt die daneben stehende Zusage
  (die zitierte Zahl) stehen, und kein Gate prüft deren Wahrheitsgehalt.
- **Folge-Slices:** [slice-169](../in-progress/slice-169-agents-37-messstaende-gegen-v5180.md) — die vier
  `AGENTS.md`-§3.7-Treffer als Architect-Schreibakt, Mitglied von
  [welle-14](../welle-14-re-baseline.md) §4.
- **Risiken aus §6:** zwei benannt, zwei mit genau einem Ausgang — beide **entfallen**. (1) *Tag
  gezogen, Zahl stehen gelassen*: Jede der 37 nachgemessenen Stellen trägt im Diff neben der
  geänderten Pfadzeile eine neu gefahrene oder ausdrücklich als unverändert bestätigte
  Ergebniszeile; wo das Ergebnis sprang, ist die Folgerung gezogen (slice-114: *zwei fehlende
  Abschnitte* → **einer**). (2) *Ein Teil der Treffer gehört dem Architect*: nicht eingetreten —
  die vier `AGENTS.md`-§3.7-Treffer sind unberührt und als Folge-Slice übergeben; berührt hat
  dieser Lauf allein §1 derselben Datei, den §3.8 nicht bindet.
- **Drei Paarungen:** hier **nicht** geprüft. Dieses Repo führt Wellen-Betrieb, und dieser Slice
  ist Mitglied von [welle-14](../welle-14-re-baseline.md); Modul 6 §Wellen-Closure-Prozedur legt
  die Paarungen auf Closure-Schritt 3c.

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
führt keine engere, und die Treffer liegen quer über den Baum.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-009` (*Fix ändert die Ableitung, die Zusage
daneben bleibt stehen*, Schwelle erreicht) trägt genau die Unterklasse, die dieser Slice abarbeitet
— ihre Stand-Zelle nennt *„Präsens-Satz über den vendored Baum"* ausdrücklich als offen und
sensorlos. `BEO-015` (*Zahl steht neben einem nie gefahrenen Kommando*) bindet die Arbeitsweise
dieses Durchgangs. Zähler-Stände siehe [Register](../observations.md). Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.

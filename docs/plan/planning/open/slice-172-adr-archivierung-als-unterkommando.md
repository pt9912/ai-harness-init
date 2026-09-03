# Slice slice-172: Der Träger der Wellen-Archivierung wird entschieden

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD unten; ein repo-weiter Beleg darüber
hinaus steht in keinem Kriterium (Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht,
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)).

**Bezug:**
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)
(die emittierte Anleitung, deren Schritt 4 heute ein Werkzeug nennt, das kein Ziel hat),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(das Ziel bleibt über `bash + git + docker` geschlossen),
[ADR-0003](../../adr/0003-go-native-binaries.md) (native Binaries als Vertriebsform),
[ADR-0022](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
(die Präzedenz: eine neue Fähigkeit als Unterkommando des Produkt-Binärs, samt der
Abzählung nach der **Herkunft des ausführbaren Bildes**).

**Berührte Spec-Stellen:** `—` — die Entscheidung deklariert ihre eigene Schärfung; dieser
Slice bewegt keine Spec-Stelle.

**Verantwortlich:** Architect

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Eine ADR entscheidet den Träger der Wellen-Archivierung: Unterkommando des Produkt-Binärs,
Shell-Helfer je Dogfood-Repo, oder eigenständiges Go-Modul.**

Die Frage steht, weil zwei Antworten nebeneinander liegen. Dieses Repo baut den Schritt als
Shell-Helfer ([slice-170](../in-progress/slice-170-archivierungs-werkzeug.md)); im Nachbar-Repo
`/Development/d-check/tools/archive-wave/` läuft dieselbe Operation als eigenständiges Go-Modul
mit eigenem `go.mod`, `Dockerfile` und `Makefile`. Für eine dritte Antwort besteht eine
angenommene Präzedenz: [ADR-0022](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
hat für die Erfassungsschicht entschieden, dass der Träger das laufende Produkt-Binär ist und die
Fähigkeit sein Unterkommando — mit dem Ergebnis, dass jedes gebootstrappte Ziel sie bekommt.
Solange die Frage offen ist, sagt der emittierte Anweisungssatz für Schritt 4 *„Hat dein Repo das
Werkzeug nicht, ist die Bedingung nicht eingetreten"*
(`grep -c 'ist die Bedingung nicht eingetreten' internal/emit/templates/commands/close-welle.md`
→ **1**; kein Erwartungswert,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — kein Ziel hat es.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Die ADR liegt und entscheidet vier benannte Fragen** — Status und, falls `Proposed`, der
      Acceptance-Trigger stehen in ihr:
      **(a) den Träger**, mit einer Abzählung nach dem Muster von
      [ADR-0022](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
      §Die Abzählung der Wege — Kriterium zuerst, Mitglieder danach;
      **(b) was mit dem heutigen Shell-Helfer geschieht** — zwei Träger für eine Operation
      driften, und `make archive-welle` kann nur einen fahren;
      **(c) woraus die Stubs entstehen** — dieses Repo bindet ein neues Artefakt an den `cp` aus
      der vendored Vorlage, das Vorbild formatiert den Stub-Text im Code (`stub.go`);
      **(d) ob die Fähigkeit ins Ziel geht und woran ein Ziel sie erreicht** — der Träger aus
      [ADR-0022](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) liegt
      gitignored, ein frischer Klon hat ihn nicht (dort Festlegung 5b).
- [ ] **Die drei am Shell-Helfer rot gesehenen Zusagen stehen als Abnahme-Kriterien in der ADR**,
      je mit dem Fall, an dem sie bricht: **(1)** der fail-closed-Wächter gegen einen lebenden
      Verweis auf einen zu löschenden Review-Report schließt `docs/reviews/**` **nicht** aus —
      `for r in docs/reviews/*.md; do rb=$(basename "$r"); grep -rlF -e "]($rb)" docs/reviews/ | grep -v "^$r$"; done | sort -u | wc -l`
      zählt die Report-Dateien, die Ziel eines Links aus einem *anderen* Report sind (kein
      Erwartungswert,
      [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2); **(2)** die Sauberkeits-Prüfung deckt **untrackte** Dateien und das Staging
      nennt explizite Pfade statt `-A`, sonst trägt der Self-Close-Commit fremden Inhalt;
      **(3)** ein Stub-Verweis der aufsteigenden Form (`../<datei>.md`) wird beim **Folgelauf**
      nachgezogen, wenn sein Ziel eine Ebene tiefer wandert.
- [ ] `make gates` grün.
- [ ] Doku-Update: der ADR-Index ([`docs/plan/adr/README.md`](../../adr/README.md)) bekommt seine
      Zeile — derivatives Register derselben schreibenden Rolle
      ([ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)).
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
| `docs/plan/adr/<NNNN>-<titel>.md` | neu | die Entscheidung, per `cp` aus der vendored ADR-Vorlage |
| [`docs/plan/adr/README.md`](../../adr/README.md) | update | Index-Zeile, derivativ ([ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-170](../in-progress/slice-170-archivierungs-werkzeug.md)
liegt in `done/` — dort liegt der Shell-Helfer, dessen Ablösung Frage (b) entscheidet, und dort
sind die drei Zusagen aus DoD (2) rot gesehen worden.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Träger-Frage (a) und die
  Emissions-Frage (d) verschiedene Abzählungen verlangen — die erste zählt nach der Herkunft des
  ausführbaren Bildes, die zweite nach dem Weg ins fremde Repo. Dann sind es zwei Entscheidungen
  und zwei Slices.
- `in-progress` → `open` (blockiert — Carveout?): wenn eine Festlegung das **Vertrags-Stratum**
  bewegt — etwa weil die Aufzählung in
  [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) um
  eine Fähigkeit wächst. Das entscheidet ein Change Request, kein Architect-Lauf
  ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)).

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; `make gates` grün (`docs-check` deckt die Kennungs-Links der neuen ADR und die
Index-Zeile); Closure-Notiz mit Steering-Loop-Lerneintrag.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Das Vorbild steht in keinem Rang der Source Precedence.** `/Development/d-check/tools/archive-wave/`
  ist ein Nachbar-Repo, kein kanonischer Rang; eine ADR, die es als **Begründung** zitiert, beruft
  sich auf eine Quelle, die kein Rang deckt. Tragen kann es nur als **gemessenes** Vorbild — eine
  Aussage über seinen Bestand mit dem Kommando daneben. — **Ausgang:** <eingetreten: CO-NNN /
  slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im Register>
- **Der ADR-Text kann eine Adresse nennen, die der Prozess selbst bewegt** — `BEO-017` im
  [Register](../observations.md) führt die Klasse mit drei ADR-tragenden Instanzen: der `git mv`,
  den Modul 5 und Modul 6 vorschreiben, bricht den Zeiger in einem nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefrorenen Artefakt. Dieser Slice ist besonders
  exponiert: seine Gegenstände sind ein Slice in `in-progress/` und eine Datei unter
  `harness/tools/`, die Frage (b) womöglich streicht. — **Ausgang:** <eingetreten: CO-NNN /
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
- **Beobachtungs-Register (`../observations.md`):** <neue `BEO-<NNN>` angelegt (Sub-Area, 1×, Beleg slice-NNN) | `BEO-<NNN>` auf <N>× erhöht, Beleg slice-NNN ergänzt | keine Beobachtung angefallen>
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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — `docs/plan/adr/` liegt
in keiner engeren Sub-Area der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area).

**Vorgelagert — offene Beobachtungen sichten:** Zwei Treffer im [Register](../observations.md).
`BEO-017` (2×, offen — ein vorgeschriebener Ortswechsel macht eine Adresse in einem eingefrorenen
Artefakt tot) steht als Risiko in §6. `BEO-007` (4×, geplant — wer die Anweisungssätze unter
`.claude/commands/` schreiben darf, sagt keine Quelle) ist berührt, aber kein Risiko dieses
Slice: Frage (d) entscheidet nur **ob** die Fähigkeit ins Ziel geht; wer den emittierten
Anweisungssatz dann **schreibt**, ist die offene Hälfte jener Zeile und Gegenstand von
[slice-174](slice-174-archivierung-emittieren.md). Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.

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
Shell-Helfer ([slice-170](../done/slice-170-archivierungs-werkzeug.md)); im Nachbar-Repo
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

- [x] **Die ADR liegt und entscheidet vier benannte Fragen** — Status und, falls `Proposed`, der
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
- [x] **Die drei am Shell-Helfer rot gesehenen Zusagen stehen als Abnahme-Kriterien in der ADR**,
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
- [x] `make gates` grün.
- [x] Doku-Update: der ADR-Index ([`docs/plan/adr/README.md`](../../adr/README.md)) bekommt seine
      Zeile — derivatives Register derselben schreibenden Rolle
      ([ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)).
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
| `docs/plan/adr/<NNNN>-<titel>.md` | neu | die Entscheidung, per `cp` aus der vendored ADR-Vorlage |
| [`docs/plan/adr/README.md`](../../adr/README.md) | update | Index-Zeile, derivativ ([ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-170](../done/slice-170-archivierungs-werkzeug.md)
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
  Aussage über seinen Bestand mit dem Kommando daneben. — **Ausgang:** **entfallen** — die ADR
  spricht die Abgrenzung selbst aus (§Was die Entscheidung auslöst, letzter Absatz: das Vorbild
  trägt *„als gemessenes Vorbild … nicht als Begründung"*), und jede ihrer zwei Aussagen über
  dessen Bestand steht neben ihrem Kommando. Die tragenden Gründe der Wahl sind der Prüfbereich,
  der entfallende Pin und die Reichweite ins Ziel — keiner davon beruft sich auf das Nachbar-Repo.
- **Der ADR-Text kann eine Adresse nennen, die der Prozess selbst bewegt** — `BEO-017` im
  Register führt die Klasse mit drei ADR-tragenden Instanzen: der `git mv`,
  den Modul 5 und Modul 6 vorschreiben, bricht den Zeiger in einem nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefrorenen Artefakt. Dieser Slice ist besonders
  exponiert: seine Gegenstände sind ein Slice in `in-progress/` und eine Datei unter
  `harness/tools/`, die Frage (b) womöglich streicht. — **Ausgang:** **entfallen** — die ADR trägt
  keine bewegliche Pfad-Adresse, gemessen über beide Adress-Formen, die
  [ADR-0030](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 4
  trennt: `grep -cE 'archive-welle\.(sh|bats)' docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md`
  → **0**; Markdown-Link in den Planning-Baum: `grep -coE '\]\([^)]*planning/[^)]*\)' <dieselbe
  Datei>` → **0**. Als Inline-Code stehen dort drei Planning-Pfade, und keiner ist beweglich: ein
  Verzeichnis, ein Glob in den vendored Baum und ein tag-loser Platzhalter — genau die Formen, die
  jene Festlegung 3 als ortsfest führt. Der Slice erscheint nur als **Kennung** in der
  Geschichte-Tabelle. Keine Erwartungswerte
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Closure-Kriterien (beobachtet, nicht behauptet):**

1. **Die Entscheidung liegt und ist im Index geführt** —
   [ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) (`Proposed`, mit
   Acceptance-Trigger) entscheidet die vier Fragen (a)–(d) und trägt die drei Abnahme-Kriterien
   je mit dem Fall, an dem sie brechen.
2. **`make gates` grün** nach dem Commit dieser Notiz; der Stop-Hook-Stempel deckt den
   Arbeitsbaum.

- **Was hat funktioniert:** Die Präzedenz wurde **geprüft statt zitiert**, und die Prüfung
  bewegte die Entscheidung: von drei Teilen der Berufung auf
  [ADR-0022](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) tragen zwei, der
  dritte nicht. Die Abzählung ist darum eine **eigene** über die Herkunft des *ausführenden
  Artefakts* — die Transport-Frage jener ADR ist im Dogfood leer —, und die Kopplung zwischen
  beiden Fragen ist am Kriterium belegt statt behauptet: jedes Mitglied fällt in genau eine
  Klasse dort, für zwei ihrer vier ist der Ausgang bereits entschieden. Die Rückführung aus §4
  feuert deshalb nicht.
- **Was ging anders als geplant:** §1 dieses Plans fasste die Präzedenz eine Stufe zu stark
  zusammen — *„mit dem Ergebnis, dass jedes gebootstrappte Ziel sie bekommt"*, während jene
  Festlegung 5(a)/(b) genau das ausschließt (die Platzierung kann scheitern, und der Träger liegt
  gitignored). Die Korrektur ist nicht kosmetisch: Festlegung 4 der neuen ADR ist deshalb
  **ortsgebunden** — *die Fähigkeit liegt, wo der Träger liegt* — statt allquantifiziert. Dazu
  brach der Lifecycle-Move dieses Slice sieben präfixlose Verweise in zwei Plandateien, die
  eingehende Hälfte, die `make slice-mv` nicht deckt.
- **Steering-Loop-Eintrag: eine benannte Lücke** — *Ein Plan-Artefakt fasst eine referenzierte
  Entscheidung zusammen, und die Zusammenfassung ist stärker als die Quelle; kein Modul aus
  `modules:` der [`.d-check.yml`](../../../../.d-check.yml) hält eine Zusammenfassung gegen das
  Artefakt, auf das sie zeigt — `links` prüft die Auflösbarkeit, nicht die Aussage.* Kein Zielort
  — die Lücke ist **benannt**, nicht verkörpert, und liegt als `BEO-027` im
  Register.
- **Beobachtungs-Register (`../observations.md`):** `BEO-003` auf **5×** erhöht, Beleg
  `slice-172` ergänzt — der `open/` → `in-progress/`-Move brach die präfixlose Form in zwei
  Plandateien, `make docs-check` meldete **7** `target-missing`. Neu: `BEO-027` (Zusammenfassung
  stärker als die zusammengefasste Quelle), 1×, Beleg `slice-172`. `BEO-017` ist in §6 zitiert
  und **nicht** erhöht: der Risiko-Ausgang dort ist *entfallen*, also kein neues Auftreten.
- **Folge-Slices:** keiner geschnitten. [slice-173](../done/slice-173-archive-welle-als-unterkommando.md)
  und [slice-174](../open/slice-174-archivierung-emittieren.md) liegen vor diesem Lauf in `open/`
  und sind die Umsetzung dieser Entscheidung, nicht ihr Ergebnis; ihr Umfang deckt sich mit den
  Festlegungen 1–4 (Port, Ablösung des Shell-Helfers, Stub-Quelle, Reichweite ins Ziel).
- **Risiken aus §6:** zwei benannt, beide **entfallen** — siehe §6.
- **Drei Paarungen** (dieser Slice ist wellenlos, also hier geprüft — **nach** dem `git mv`):
  (a) **Anker** — kein Eintrag trägt das Feld `liegt in`, also kein Gegenstand; (b)
  **Folge-Slice** — keiner genannt, also kein Gegenstand; die zwei zitierten Umsetzungs-Slices
  sind Dateien im Planning-Lifecycle (`ls docs/plan/planning/*/slice-17[34]-*.md` → je `open/`);
  (c) **Register** — die drei hier zitierten Kennungen haben je eine Zeile, und jede Zeile des
  Registers trägt mindestens einen Beleg
  (`awk -F'|' 'NR>1 && /^\| BEO-/ {if ($6 !~ /slice-/) print $2}' docs/plan/planning/observations.md`
  → leer).

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

**Vorgelagert — offene Beobachtungen sichten:** Zwei Treffer im Register.
`BEO-017` (2×, offen — ein vorgeschriebener Ortswechsel macht eine Adresse in einem eingefrorenen
Artefakt tot) steht als Risiko in §6. `BEO-007` (4×, geplant — wer die Anweisungssätze unter
`.claude/commands/` schreiben darf, sagt keine Quelle) ist berührt, aber kein Risiko dieses
Slice: Frage (d) entscheidet nur **ob** die Fähigkeit ins Ziel geht; wer den emittierten
Anweisungssatz dann **schreibt**, ist die offene Hälfte jener Zeile und Gegenstand von
[slice-174](../open/slice-174-archivierung-emittieren.md). Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.

# Slice slice-173: `ai-harness-init archive-welle` als Unterkommando

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD unten; ein repo-weiter Beleg darüber
hinaus steht in keinem Kriterium (Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht,
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)).

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein benanntes Target läuft auf frischem Checkout),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(der Host braucht `git`, `docker` und `make`, sonst nichts),
[ADR-0003](../../adr/0003-go-native-binaries.md) (native Binaries als Vertriebsform),
[ADR-0022](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 2
(Fähigkeiten sind Unterkommandos **desselben** Trägers, und der Dogfood fährt denselben
Einstiegspunkt) — die Träger-Festlegung selbst trifft
[slice-172](../in-progress/slice-172-adr-archivierung-als-unterkommando.md).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** Implementer

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Schritt 4 der Wellen-Closure läuft als Unterkommando des Produkt-Binärs statt als
Shell-Helfer.**

Die Logik wird **portiert, nicht entworfen**: `/Development/d-check/tools/archive-wave/` fährt
dieselbe Operation gegen dasselbe `docs/plan/planning/`-Layout und trennt sie in vier Gegenstände
mit je eigenem Test — Einsammeln, Verweis-Nachzug, Stub, Zip. Das begrenzt die Review-Fläche auf
einen **Vergleich gegen ein benanntes Vorbild** plus das gemessene Delta, statt auf einen Entwurf.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **`ai-harness-init archive-welle` existiert** — Zweig im `main()`-Dispatch neben
      `span-emit`/`span-report`, Logik unter `internal/archive/` in den vier Gegenständen des
      Vorbilds, je mit Go-Test. **Drei Abweichungen vom Vorbild sind gemessen und umgesetzt:**
      (i) die Kennungs-Form dieses Repos — d-checks Muster für die im Stub überlebenden Kennungen
      verlangt nach `FA-` mindestens einen Großbuchstaben und trifft `LH-FA-<NN>` damit nicht,
      während `LH-QA-<NN>` durchgeht; (ii) die Stub-Erzeugung nach Festlegung (c) aus
      [slice-172](../in-progress/slice-172-adr-archivierung-als-unterkommando.md) — das Vorbild formatiert den
      Stub-Text im Code; (iii) die Einsammel-Regel um die **wellenlosen** Slices seit der letzten
      Closure, die das Vorbild in seiner `README.md` §Grenzen ausdrücklich ausschließt, während
      der Anweisungssatz dieses Repos sie verlangt.
- [ ] **Die drei am Shell-Helfer rot gesehenen Zusagen halten, je einmal rot gesehen** — die
      Abnahme-Kriterien aus [slice-172](../in-progress/slice-172-adr-archivierung-als-unterkommando.md) DoD (2):
      Hänger-Wächter **ohne** `docs/reviews`-Ausschluss · Sauberkeits-Prüfung deckt untrackte
      Dateien und stagt mit expliziten Pfaden · der aufsteigende Stub-Verweis (`../<datei>.md`)
      wird beim **Folgelauf** nachgezogen. Das Vorbild deckt die dritte konstruktiv (sein Nachzug
      läuft rekursiv über den ganzen Baum und löst jedes Ziel relativ zur verweisenden Datei auf);
      die ersten beiden führt es nicht — es fasst keinen `git`-Zustand an.
- [ ] **`make archive-welle` fährt den Träger**, und der Shell-Helfer samt seinem bats-Satz folgt
      Festlegung (b) aus [slice-172](../in-progress/slice-172-adr-archivierung-als-unterkommando.md) — zwei
      Fassungen derselben Operation nebeneinander sind der Zustand, den dieser Punkt beendet.
- [ ] `make gates` grün.
- [ ] Doku-Update: [`harness/README.md`](../../../../harness/README.md) beschreibt das Target —
      was es prüft und was nicht, und dass es außerhalb von `make gates` steht.
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
| `internal/archive/` | neu | Einsammeln · Verweis-Nachzug · Stub · Zip, je mit Go-Test — die vier Gegenstände des Vorbilds |
| `cmd/ai-harness-init/archive_welle.go` | neu | Unterkommando-Zweig nach dem Muster von `span_emit.go` / `span_report.go` |
| `Makefile` | update | `archive-welle` zeigt auf den Träger statt auf den Shell-Helfer |
| `harness/tools/archive-welle.sh`, `test/archive-welle.bats` | nach Festlegung (b) | zwei Fassungen derselben Operation driften |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-172](../in-progress/slice-172-adr-archivierung-als-unterkommando.md)
liegt in `done/` — Träger, Stub-Quelle, Umgang mit dem Shell-Helfer und die drei Abnahme-Kriterien
stehen dort.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn Port und die drei Zusagen zusammen
  **nicht in einer Review-Sitzung** prüfbar sind. Die Messlatte liegt vor und ist keine Schätzung
  — `wc -l harness/tools/archive-welle.sh test/archive-welle.bats` für den Shell-Helfer, der aus
  **einem** Durchgang drei blockierende Befunde trug, und
  `wc -l /Development/d-check/tools/archive-wave/*.go` für das Vorbild (keine Erwartungswerte,
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Dann geht der **Port** als eigener Slice zurück, und die drei Zusagen bleiben hier.
- `in-progress` → `open` (blockiert — Carveout?): wenn Festlegung (a) den Träger nicht auf das
  Produkt-Binär legt — dann hat dieser Slice keinen Gegenstand.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; ein Probelauf über eine geschlossene Welle dieses Repos ist gefahren und sein
Ergebnis genannt; `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Ein Port erbt die Grenzen des Vorbilds.** Dessen `README.md` §Grenzen nennt selbst, dass ein
  Verzeichnis-Präfix-Verweis aus einer **Nicht-Wurzel**-Datei still übersehen statt gemeldet wird
  — dieselbe Klasse, die `BEO-003` im [Register](../observations.md) als *eingehende Hälfte der
  präfixlosen Form* führt (4×, verkörpert in `make slice-mv` mit benannter Grenze). Was der Port
  nicht deckt, gehört benannt statt geerbt. — **Ausgang:** <eingetreten: CO-NNN / slice-NNN |
  entfallen: Grund | weiter offen: → BEO-NNN im Register>
- **Ob zwei Läufe dasselbe Archiv liefern, ist am Vorbild ungemessen.** Der Shell-Helfer belegte
  die Eigenschaft über einen Tree-Operanden, dessen Eintrags-Zeitstempel aus der Commit-Zeit
  kommen; das Vorbild schreibt das Zip aus der Standardbibliothek und setzt die Zeit anders. Kein
  Gate liest in ein Zip hinein — was ein zweiter Lauf belegt, ist zu **messen**, nicht zu
  übernehmen. — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen:
  → BEO-NNN im Register>
- **Der Port nimmt Zusagen aus dem Kopf des Shell-Helfers mit, deren Ableitung er ändert** —
  genau die Klasse `BEO-009` im [Register](../observations.md) (8×, geplant): ein Fix korrigiert
  die Ableitung und lässt die daneben stehende Zusage unverändert stehen. Betroffen sind die
  Grenzen-Liste im Skriptkopf und die Beschreibung in
  [`harness/README.md`](../../../../harness/README.md). — **Ausgang:** <eingetreten: CO-NNN /
  slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im Register>
- **Zwei offene LOW des Vorbilds wandern wortgleich in den Port, wenn sie niemand benennt.** Die
  zweite Review-Runde von [slice-170](../done/slice-170-archivierungs-werkzeug.md) ließ sie
  stehen: `titel_von` lässt bei der H1-Form `# Slice <NNN>: T` die Nummer im Titel stehen, obwohl
  der Kommentar daneben zusagt, eine Zeile ohne Kennung bleibe ganz stehen; `unsauber_grund` zählt
  Zeilen aus `git status --porcelain` und nennt sie „Datei(en)", während eine Zeile ein untracktes
  Verzeichnis sein kann. Die Klassen liegen als `BEO-025` und `BEO-026` im
  [Register](../observations.md). — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen:
  Grund | weiter offen: → BEO-NNN im Register>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `*` (gesamtes Repo) und `harness/tools/` —
beide führt die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area);
`cmd/` und `internal/` liegen in keiner engeren.

**Vorgelagert — offene Beobachtungen sichten:** Zwei Treffer, beide als Risiko in §6:
`BEO-003` (4×, verkörpert in `make slice-mv` mit ausdrücklich benannter Grenze) und `BEO-009`
(8×, geplant). Beide stehen im [Register](../observations.md); keiner erreicht mit diesem Slice
die Schwelle neu. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.

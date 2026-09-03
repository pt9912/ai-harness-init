# Slice slice-175: Der schreibende Pfad von `archive-welle` und die Ablösung des Shell-Helfers

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
(ein benanntes Target fährt das, was daneben steht),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(der vierte gepinnte Bild-Digest verliert hier seinen Gegenstand),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(der Host braucht `git`, `docker` und `make`, sonst nichts),
[ADR-0003](../../adr/0003-go-native-binaries.md) (native Binaries als Vertriebsform),
[ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) (`Proposed` mit
Acceptance-Trigger — Festlegung 2 der Zeitpunkt der Ablösung, Festlegung 3 die Stub-Quelle, dazu
die Folgepflichten 1–4).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** `—` bis zur Priorisierung (Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine — das Feld wird beim Übergang
`open` → `next` gesetzt).

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Der Träger tut, was der Vorschau-Zweig sagt — und wird dabei der einzige.**

`ai-harness-init archive-welle` schreibt: Move und Commit 1, das Zip aus der Standardbibliothek,
beide Stub-Arten aus der vendored Vorlage, den Nachzug der in
[slice-173](../in-progress/slice-173-archive-welle-als-unterkommando.md) gefundenen Verweise, explizites
Staging und Commit 2. Mit demselben Lauf zeigt `make archive-welle` auf den Träger, und der
Shell-Helfer samt seinem bats-Satz geht — Festlegung 2 aus
[ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) bindet die Ablösung an genau
diesen Lauf, *„nicht davor und nicht danach"*.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **`ai-harness-init archive-welle <welle>` führt die Operation aus** — Move und Commit 1
      (reiner `git mv`, kein Byte Inhalt), das Zip aus der Standardbibliothek, der Nachzug der
      drei Verweis-Formen, explizites Staging und Commit 2, je mit Go-Test über einem
      synthetischen Baum.
- [ ] **Beide Stub-Arten entstehen aus der vendored Vorlage, und ohne sie bricht der Lauf ab** —
      Festlegung 3 aus [ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md): keine
      im Code formatierte zweite Fassung der Form. **Rot zu sehen:** die Vorlage im Prüfbaum
      entfernen — der Lauf muss fallen, statt eine Form zu erfinden. Dazu die **zwei schreibenden
      Abnahme-Kriterien** jener ADR, je einmal rot gesehen: das Staging nennt explizite Pfade
      statt `-A` (rot: `-A` stagen, eine untrackte Fremddatei danebenlegen) und der aufsteigende
      Stub-Verweis (`../<datei>.md`) wird beim **Folgelauf** nachgezogen (rot: die aufsteigende
      Ersetzungsrichtung entfernen). Zusammen mit den zwei lesenden aus
      [slice-173](../in-progress/slice-173-archive-welle-als-unterkommando.md) ist Folgepflicht 1 jener
      ADR damit erfüllt.
- [ ] **`make archive-welle` fährt den Träger, und er ist der einzige** — Festlegung 2 und die
      Folgepflichten 2–4: `harness/tools/archive-welle.sh` und `test/archive-welle.bats` sind
      entfernt; jeder der **sieben** Mutations-Fälle
      (`grep -l 'archive-welle' test/mutations/*.sh | wc -l`) ist auf den neuen Träger gezogen
      **oder** beim Entfernen einzeln benannt — still verschwinden darf keiner; der vierte
      gepinnte Bild-Digest verlässt das Makefile mit seinem Aufrufer
      (`grep -cE '^[A-Z_]+_IMAGE \?=' Makefile`; keine Erwartungswerte,
      [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2).
- [ ] `make gates` grün.
- [ ] Doku-Update: [`harness/README.md`](../../../../harness/README.md) beschreibt das Target am
      neuen Träger — was es tut, was es **nicht** prüft, und dass es außerhalb von `make gates`
      steht; die Grenzen-Zusagen des alten Skriptkopfs stehen dort nach, soweit sie weiter gelten
      (Folgepflicht 3).
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
| `internal/archive/` | update | Zip · Stub aus Vorlage · Anwenden des Verweis-Nachzugs · die zwei Commits, je mit Go-Test — die schreibenden Gegenstände (`archive.go`, `stub.go` des Vorbilds) |
| `cmd/ai-harness-init/archive_welle.go` | update | der Zweig führt die Operation, nicht nur die Vorschau |
| `Makefile` | update | `archive-welle` zeigt auf den Träger; der vierte Bild-Pin verliert seinen Aufrufer |
| `harness/tools/archive-welle.sh`, `test/archive-welle.bats` | entfernt | Festlegung 2 — zwei Fassungen derselben Operation driften |
| `test/mutations/` | update | die sieben Fälle wandern mit oder werden einzeln benannt (Folgepflicht 2) |
| [`harness/README.md`](../../../../harness/README.md) | update | Folgepflicht 3 — die Beschreibung folgt dem Träger |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-173](../in-progress/slice-173-archive-welle-als-unterkommando.md) liegt in `done/` — vorher gibt
es weder das Einsammeln noch den Verweis-Fund, auf denen der schreibende Pfad aufsetzt.

**Dieser Slice ist der tragende Vorgänger von
[slice-174](../open/slice-174-archivierung-emittieren.md), nicht
[slice-173](../in-progress/slice-173-archive-welle-als-unterkommando.md).** Dessen §4 nennt heute noch
slice-173; nach diesem Schnitt ist das zu früh: Folgepflicht 5 aus
[ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) lässt den emittierten
Anweisungssatz erst auf das Kommando zeigen, *wenn es läuft*, und ein Vorschau-Zweig archiviert
nicht. Wer slice-174 priorisiert, zieht seinen Start-Trigger hierher.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn Stub-Erzeugung und Ablösung
  zusammen nicht in *einer* Review-Sitzung prüfbar sind. Die Messlatte ist die Schreib-Hälfte des
  Vorbilds — `wc -l /Development/d-check/tools/archive-wave/{archive,stub}.go` — plus die
  Ablösung; der Stub ist der einzige Gegenstand dieses Slice, den das Vorbild **nicht** trägt
  (Festlegung 3 verlangt die Vorlage, das Vorbild formatiert im Code). Dann geht der Stub als
  eigener Slice zurück und die Ablösung bleibt hier — Festlegung 2 bindet sie an den Lauf, der
  die Operation liefert.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Zwei-Commit-Trennung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.3 im Go-Träger nicht ohne roten Stop-Hook-Stempel
  läuft — dann ist der Aufruf-Kontext der Operation zu entscheiden, nicht ihr Code.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; ein Lauf über eine geschlossene Welle dieses Repos ist gefahren, seine zwei
Commits liegen (`git show --stat` auf Commit 1 zeigt reine Renames) und `make docs-check` ist
danach grün; `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Ob zwei Läufe dasselbe Archiv liefern, ist am Vorbild ungemessen.** Der Shell-Helfer belegte
  die Eigenschaft über einen Tree-Operanden, dessen Eintrags-Zeitstempel aus der Commit-Zeit
  kommen; das Zip aus der Standardbibliothek setzt die Zeit anders. Kein Gate liest in ein Zip
  hinein — was ein zweiter Lauf belegt, ist zu **messen**, nicht zu übernehmen
  ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). — **Ausgang:**
  <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im Register>
- **Die Ablösung nimmt Zusagen aus dem Kopf des Shell-Helfers mit, deren Ableitung sie ändert** —
  genau die Klasse `BEO-009` im [Register](../observations.md) (8×, geplant): ein Fix korrigiert
  die Ableitung und lässt die daneben stehende Zusage stehen. Betroffen sind die Grenzen-Liste im
  Skriptkopf und die Beschreibung in [`harness/README.md`](../../../../harness/README.md)
  (Folgepflicht 3). — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter
  offen: → BEO-NNN im Register>
- **`titel_von` trägt einen offenen LOW in den Port**, wenn ihn niemand benennt: bei der H1-Form
  `# Slice <NNN>: T` bleibt die Nummer im Titel stehen, obwohl der Kommentar daneben zusagt, eine
  Zeile ohne Kennung bleibe ganz stehen — die Klasse `BEO-025` im [Register](../observations.md)
  (1×, offen). Die Funktion speist den Stub und liegt damit in diesem Slice. — **Ausgang:**
  <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im Register>
- **Ein still verschwindender Mutations-Fall verengt die bewachte Fläche, ohne dass ein Gate es
  meldet.** `make mutate` kennt keine Fehlschlag-Form für einen Fall, den es **nicht** mehr gibt;
  der Träger von Folgepflicht 2 ist die Aufzählung in der Closure-Notiz, kein Sensor. —
  **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im
  Register>

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
`cmd/`, `internal/` und `test/mutations/` liegen in keiner engeren.

**Vorgelagert — offene Beobachtungen sichten:** Zwei Treffer im [Register](../observations.md),
beide als Risiko in §6: `BEO-009` (8×, geplant — eine geänderte Ableitung lässt die Zusage daneben
stehen) und `BEO-025` (1×, offen — eine Zusage im Funktionskopf nennt einen Geltungsbereich, den
der Code darunter nicht hält). Keiner erreicht mit diesem Slice die Schwelle neu. Weitere Treffer:
keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.

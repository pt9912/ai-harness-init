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

**Verantwortlich:** Implementation (ai-harness-init-Team, pt9912) — gesetzt beim Übergang
`open` → `next` (Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine).

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Der Träger tut, was der Vorschau-Zweig sagt — und wird dabei der einzige.**

`ai-harness-init archive-welle` schreibt: Move und Commit 1, das Zip aus der Standardbibliothek,
beide Stub-Arten aus der vendored Vorlage, den Nachzug der in
[slice-173](../done/slice-173-archive-welle-als-unterkommando.md) gefundenen Verweise, explizites
Staging und Commit 2. Mit demselben Lauf zeigt `make archive-welle` auf den Träger, und der
Shell-Helfer samt seinem bats-Satz geht — Festlegung 2 aus
[ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) bindet die Ablösung an genau
diesen Lauf, *„nicht davor und nicht danach"*.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **`ai-harness-init archive-welle <welle>` führt die Operation aus** — Move und Commit 1
      (reiner `git mv`, kein Byte Inhalt), das Zip aus der Standardbibliothek, der Nachzug der
      drei Verweis-Formen, explizites Staging und Commit 2, je mit Go-Test über einem
      synthetischen Baum.
- [x] **Beide Stub-Arten entstehen aus der vendored Vorlage, und ohne sie bricht der Lauf ab** —
      Festlegung 3 aus [ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md): keine
      im Code formatierte zweite Fassung der Form. **Rot zu sehen:** die Vorlage im Prüfbaum
      entfernen — der Lauf muss fallen, statt eine Form zu erfinden. Dazu die **zwei schreibenden
      Abnahme-Kriterien** jener ADR, je einmal rot gesehen: das Staging nennt explizite Pfade
      statt `-A` (rot: `-A` stagen, eine untrackte Fremddatei danebenlegen) und der aufsteigende
      Stub-Verweis (`../<datei>.md`) wird beim **Folgelauf** nachgezogen (rot: die aufsteigende
      Ersetzungsrichtung entfernen). Zusammen mit den zwei lesenden aus
      [slice-173](../done/slice-173-archive-welle-als-unterkommando.md) ist Folgepflicht 1 jener
      ADR damit erfüllt.
- [x] **`make archive-welle` fährt den Träger, und er ist der einzige** — Festlegung 2 und die
      Folgepflichten 2–4: `harness/tools/archive-welle.sh` und `test/archive-welle.bats` sind
      entfernt; jeder der **sieben** Mutations-Fälle
      (`grep -l 'archive-welle' test/mutations/*.sh | wc -l`) ist auf den neuen Träger gezogen
      **oder** beim Entfernen einzeln benannt — still verschwinden darf keiner; der vierte
      gepinnte Bild-Digest verlässt das Makefile mit seinem Aufrufer
      (`grep -cE '^[A-Z_]+_IMAGE \?=' Makefile`; keine Erwartungswerte,
      [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2).
- [x] `make gates` grün.
- [x] Doku-Update: [`harness/README.md`](../../../../harness/README.md) beschreibt das Target am
      neuen Träger — was es tut, was es **nicht** prüft, und dass es außerhalb von `make gates`
      steht; die Grenzen-Zusagen des alten Skriptkopfs stehen dort nach, soweit sie weiter gelten
      (Folgepflicht 3).
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
[slice-173](../done/slice-173-archive-welle-als-unterkommando.md) liegt in `done/` — vorher gibt
es weder das Einsammeln noch den Verweis-Fund, auf denen der schreibende Pfad aufsetzt.

**Dieser Slice ist der tragende Vorgänger von
[slice-174](../open/slice-174-archivierung-emittieren.md), nicht
[slice-173](../done/slice-173-archive-welle-als-unterkommando.md).** Dessen §4 nennt heute noch
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
  ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). — **Ausgang:
  entfallen** — gemessen statt übernommen: kein Eintrag des Zip trägt einen Zeitstempel aus der
  Uhr des Laufs, und `TestZipIstUeberZweiLaeufeByteGleich` (`internal/archive/anwenden_test.go`)
  hält zwei Läufe über demselben Inhalt Byte gegen Byte. Der Beleg liegt damit in `make test`
  und nicht in einer Eigenschaft, die vom Vorbild geerbt wäre
- **Die Ablösung nimmt Zusagen aus dem Kopf des Shell-Helfers mit, deren Ableitung sie ändert** —
  genau die Klasse `BEO-009` im [Register](../observations.md) (8×, geplant): ein Fix korrigiert
  die Ableitung und lässt die daneben stehende Zusage stehen. Betroffen sind die Grenzen-Liste im
  Skriptkopf und die Beschreibung in [`harness/README.md`](../../../../harness/README.md)
  (Folgepflicht 3). — **Ausgang: weiter offen** → `BEO-009` im [Register](../observations.md)
  (10×, Beleg slice-175). Das Risiko ist **an den zwei benannten Orten nicht** eingetreten: die
  Grenzen-Zusagen des Skriptkopfs stehen in [`harness/README.md`](../../../../harness/README.md)
  nach, soweit sie weiter gelten. Getroffen hat es einen **dritten** Ort, den die Eingrenzung
  nicht nannte — die `Stand`-Zellen dieses Registers, die den entfernten Pfad im Präsens führten;
  sie sind mit dieser Closure nachgezogen. Genau diese Ortsfrage ist die Klasse, und sie hat
  keinen Sensor
- **`titel_von` trägt einen offenen LOW in den Port**, wenn ihn niemand benennt: bei der H1-Form
  `# Slice <NNN>: T` bleibt die Nummer im Titel stehen, obwohl der Kommentar daneben zusagt, eine
  Zeile ohne Kennung bleibe ganz stehen — die Klasse `BEO-025` im [Register](../observations.md)
  (1×, offen). Die Funktion speist den Stub und liegt damit in diesem Slice. — **Ausgang:
  entfallen** — der Port trägt den LOW nicht weiter: `TitelVon` (`internal/archive/stub.go`)
  nennt die Form `# Slice 190: T` als **benannte** Grenze samt dem Rest, der stehen bleibt
  (`190: T`), und `TestTitelVonLaesstDenNummernRestStehen` misst die vier getroffenen Formen
  **und** diese fünfte. Die Zusage ist damit auf das eingeschränkt, was der Code hält — der
  Ausgang, den [`AGENTS.md`](../../../../AGENTS.md) §3.7 für die Klasse *Zusage* verlangt
- **Ein still verschwindender Mutations-Fall verengt die bewachte Fläche, ohne dass ein Gate es
  meldet.** `make mutate` kennt keine Fehlschlag-Form für einen Fall, den es **nicht** mehr gibt;
  der Träger von Folgepflicht 2 ist die Aufzählung in der Closure-Notiz, kein Sensor. —
  **Ausgang: entfallen** — die Aufzählung steht in §7 und trägt jeden der sieben einzeln: keiner
  ist ersatzlos verschwunden, jeder hat einen benannten Nachfolger am neuen Träger. Der Träger
  bleibt die Aufzählung; ein Sensor ist damit nicht entstanden, und das steht hier statt einer
  Zusage

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** Die Ablösung an **einem** Lauf, wie Festlegung 2 sie bindet.
  `make archive-welle WELLE=<welle-id>` hängt an `host-bin` und fährt den Träger
  (`Makefile:321-322`); `harness/tools/archive-welle.sh` und `test/archive-welle.bats` sind fort,
  und mit ihnen der vierte gepinnte Bild-Digest (`grep -cE '^[A-Z_]+_IMAGE \?=' Makefile` → **3**;
  kein Erwartungswert,
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Das Zip kommt aus der Standardbibliothek und ist über zwei Läufe byte-gleich.
  **Folgepflicht 2, die Aufzählung, die kein Sensor trägt** — von den sieben Fällen über dem
  Skript ist keiner ersatzlos verschwunden, jeder hat seinen Nachfolger am neuen Träger:
  `225-…-klasse-wellenlos` → `235`, `226-…-klasse-fremd` → `236`, `227-…-stub-ueberschrift` →
  `239`, `228-…-klasse-mitglied` → `234`, `229-…-haenger-suchraum` → `233`, `230-…-untrackt` →
  `232`, `231-…-aufsteigender-verweis` → `240`. Dazu neu, ohne Vorgänger am Skript: `241`
  (explizites Staging) und die Fälle über Dispatch, Vorschau-Schalter, Stub-Verdrahtung und
  Betriebs-Verdrahtung. Der Bestand ist `ls test/mutations/*archive-welle*.sh test/mutations/*archiv-stub-vorlage*.sh | wc -l`
  (kein Erwartungswert, dieselbe Setzung).
- **Was ging anders als geplant:** **Acht Review-Runden statt einer**, und sieben davon in *einer*
  Familie: ein Wächter sagt eine Menge zu und prüft eine engere. Die Bewegung lief von der Logik
  über den Parameter, die Strecke, die Verdrahtung und den Bedien-Einstieg bis in den Ausdruck
  des Wächters selbst — jede Runde fand die Lücke eine Ebene weiter außen, keine fand einen
  Rückschritt. Und der **Sichtungs-Schritt dieses Plans hat die Schwelle verfehlt**: §8 schloss
  aus, dass ein Registereintrag mit diesem Slice 3× erreicht, weil er zwei Zähler-Stände um je
  eins zu niedrig führte. Ohne den Review wäre der Lese-Schritt ausgeblieben; die Klasse steht
  jetzt als `BEO-030` im Register.
- **Der eine Befund, der offen bleibt, und seine Messung** (Runde 8, nicht blockierend): Der
  Kopplungs-Wächter `test/unterkommando-kopplung.bats` vergleicht gegen die Menge der
  `case`-Marken am Zeilenanfang (`dispatch_muster='^[[:space:]]*case "[^"]*":'`) und sagt daneben
  zu, eine Marke in einer Kommentar-Zeile dispatche nichts. Der Ausdruck trennt die `//`-Form ab,
  die Block-Form nicht: wird der Dispatch-Zweig umbenannt und die alte Marke in einen
  `/* … */`-Block derselben Datei gesetzt, bleibt `make test-bats` **grün**, während
  `make archive-welle` in den Init-Pfad fällt — fail-open, gemessen an einer Kopie des Baums. Für
  `archive-welle` fängt derselbe Baum in `make test-go` drei `--- FAIL:` in
  `cmd/ai-harness-init/archive_welle_echt_test.go`; für `span-report` steht daneben nichts in
  `make gates`. Dass `cmd/ai-harness-init/main.go` heute keinen Block-Kommentar führt, ist
  gemessen (`grep -cE '^[[:space:]]*/\*' cmd/ai-harness-init/main.go` → **0**; kein
  Erwartungswert, dieselbe Setzung) — das hält den Restschaden klein und schließt ihn nicht. Der
  Ausgang ist
  [slice-181](../open/slice-181-grenzen-liste-vollstaendig-oder-fail-closed.md) DoD (1), die
  Klasse `BEO-025`.
- **Steering-Loop-Eintrag:** Geschärfte Regel: **Ein Wächter, der über einer Quelldatei urteilt,
  zerlegt ihre Form — oder er urteilt nicht.** Eine Grenzen-Liste neben dem Ausdruck ist
  vollständig, oder der Ausdruck fällt über der Form, die sie nicht führt, fail-closed; eine
  Zusage, die *eine* Grenze nennt, sagt damit implizit „und sonst keine".
  Auslöser: `BEO-025` (slice-170, slice-173, slice-175 — 3×). Gezählt, nicht verkörpert: den
  Zielort schreibt der Architect, der Ausgang ist als
  [slice-181](../open/slice-181-grenzen-liste-vollstaendig-oder-fail-closed.md) zugewiesen.
- **Beobachtungs-Register (`../observations.md`):** `BEO-025` auf 3× erhöht (Beleg slice-175) —
  **Schwelle erreicht**, Lese-Schritt ausgeführt, Stand jetzt **geplant**:
  [slice-181](../open/slice-181-grenzen-liste-vollstaendig-oder-fail-closed.md). `BEO-009` auf
  10× erhöht (Beleg slice-175). Neu angelegt `BEO-030` (`*`, 1×, Beleg slice-175 — der
  Sichtungs-Schritt zitiert einen Zähler-Stand, den das Register nicht trägt). Die `Stand`-Zellen
  von `BEO-025`, `BEO-026` und `BEO-029` sind nachgezogen: sie führten den mit diesem Slice
  entfernten Shell-Träger im Präsens; kein Zähler-Schritt, eine Korrektur.
- **Folge-Slices:** [slice-181](../open/slice-181-grenzen-liste-vollstaendig-oder-fail-closed.md)
  (eine Grenzen-Liste ist vollständig oder der Ausdruck fällt fail-closed) — ist eine Datei in
  `open/`.
- **Risiken aus §6:** vier Punkte, je ein Ausgang — dreimal *entfallen* (Byte-Gleichheit
  gemessen statt geerbt · die Titel-Grenze im Port benannt und gedeckt · die sieben
  Mutations-Fälle einzeln zugeordnet), einmal *weiter offen* nach `BEO-009`.
- **Drei Paarungen:** **Anker** — keine, dieser Slice verkörpert nichts (kein `liegt in`-Feld).
  **Folge-Slice** — `slice-181` liegt in `open/`. **Register** — die fünf in diesem Plan
  genannten Kennungen (`BEO-009`, `-025`, `-026`, `-029`, `-030`) haben je eine Zeile, und jede
  Zeile des Registers trägt mindestens einen Beleg. Dieses Repo führt **Wellen-Betrieb**
  ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird));
  die nächste Welle-Closure prüft sie erneut, auch für diesen Slice ohne Wellen-Zugehörigkeit.
- **Zwei Fäden, deren Träger nicht diese Closure ist, und beide sind benannt statt still.**
  (1) [ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) steht weiter auf
  `Proposed`: ihr Acceptance-Trigger verlangt eine **Konsistenz**-Runde gegen
  [ADR-0022](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md),
  [ADR-0003](../../adr/0003-go-native-binaries.md) und
  [ADR-0007](../../adr/0007-bootstrap-phasen.md), und keiner der Reports zu slice-173/slice-175
  ist eine — jeder von ihnen sagt das über sich selbst. Träger ist der **Trigger-Audit** der
  nächsten Welle-Closure (Baseline-Regelwerk `modul-06-roadmap.md` §Wellen-Closure-Prozedur,
  Schritt 2), nicht diese Slice-Closure: dieses Repo führt Wellen-Betrieb.
  (2) **Folgepflicht 5** — der **emittierte** Anweisungssatz zeigt erst auf das Kommando, wenn es
  läuft. Es läuft jetzt; Träger ist
  [slice-174](../open/slice-174-archivierung-emittieren.md) DoD (2). Sein Start-Trigger nennt
  slice-173 und meint diesen Slice — die Differenz ist mit dieser Closure gegenstandslos, denn
  beide liegen dann in `done/`. Die **repo-eigene** Hälfte trägt slice-174 nicht: sie ist mit
  dieser Closure erledigt (`.claude/commands/close-welle.md` Schritt 4 nennt den Träger).

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
beide als Risiko in §6: `BEO-009` (eine geänderte Ableitung lässt die Zusage daneben stehen) und
`BEO-025` (eine Zusage im Funktionskopf nennt einen Geltungsbereich, den der Code darunter nicht
hält). Den Zähler-Stand nennt das Register selbst, nicht dieser Satz
(`awk -F'|' '/BEO-0(09|25)/ {print $2, $5, $6}' docs/plan/planning/observations.md`; keine
Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). **`BEO-025` erreicht mit diesem Slice die Schwelle**; sein Ausgang steht in §7. Die
Klasse, an der eine abgeschriebene Zahl diese Aussage kippen lässt, führt das Register als
`BEO-030`. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.

# Slice slice-049: Baseline-Re-Vendor v3.5.1 → v3.5.2

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Wartung — die vom `baseline-freshness`-Sensor gemeldete Tag-Drift auflösen,
wie [slice-043](slice-043-baseline-bump-v3.5.1.md) für v3.5.0→v3.5.1).

**Bezug:** [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) (committet vendored Baseline + Re-Baseline-Mechanik), [`MR-013`](../../../../harness/conventions.md#mr-013--regelwerk-check-auf-d-check-sources-tool-statt-skript) (`.d-check.yml`-`sources`-Kopplung), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Reproduzierbarkeit/Pins).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-25.

---

## 1. Ziel

Die vendored Baseline wird von `v3.5.1` auf `v3.5.2` re-vendored, alle fünf gekoppelten Pins ziehen
mit, der alte Baum weicht — **und die eine normative Ergänzung, die v3.5.2 mitbringt (Change Request
als *externer* Vorgang), wird gegen die reale Repo-Praxis gehalten und entschieden**, statt sie mit
dem Baum stillschweigend einzuziehen.

## 2. Definition of Done

- [x] **Baum re-vendored:** `.harness/baseline/v3.5.2/{regelwerk,templates}/` + `SHA256SUMS` <!-- d-check:ignore (geplant — entsteht beim Vendoren) -->
  (aus dem Release-ZIP entpackt; `SHA256SUMS` neu erzeugt: `sha256sum` über alle Dateien, Pfade relativ
  zu `<tag>/`, `LC_ALL=C`-sortiert, die Datei selbst ausgenommen — [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 2). Der alte
  `.harness/baseline/v3.5.1/`-Baum ist **entfernt** (Setzung 4: ein Tag zur Zeit).
- [x] **Provenienz-Pin:** `BASELINE_ZIP_SHA256` ([`Makefile`](../../../../Makefile)) = sha256 des v3.5.2-Release-Assets
  (`2af45aad2777cadf26127066c9a2dc43f7111ee2687e44fe2eceb95c6c0a1925`, am 2026-07-25 live gemessen);
  `BASELINE_TAG` = `v3.5.2`. **Provenienz vor dem Entpacken prüfen**, nicht danach.
- [x] **Gekoppelte Pins mitgezogen (fail-closed-Tests grün):** `DefaultTag` + `DefaultBaselineSHA256`
  ([`internal/fetch/baseline.go`](../../../../internal/fetch/baseline.go), Kopplung `TestDefaultTag_MatchesBaseline` /
  `TestDefaultBaselineSHA256_MatchesMakefile`) und der [`.d-check.yml`](../../../../.d-check.yml)-`sources`-Block (url + sha256,
  Kopplung [`test/sources-pin.bats`](../../../../test/sources-pin.bats), [`MR-013`](../../../../harness/conventions.md#mr-013--regelwerk-check-auf-d-check-sources-tool-statt-skript)).
- [x] **CR-Regel entschieden und belegt** (die *inhaltliche* Arbeit dieses Slice, s. §3 „Normativer
  Delta"): das Ergebnis steht als Adaptions-Eintrag in [`harness/conventions.md`](../../../../harness/conventions.md) — entweder
  „konform, weil …" mit benanntem Beleg oder ein **neuer `MR-*`**, der die Abweichung trägt.
  **Nicht** als Prosa in einer Slice-Notiz: die Regel überlebt den Slice, die Notiz nicht.
- [x] **`spec/lastenheft.md` bleibt in diesem Slice unberührt** — und zwar belegt (`git diff --stat`
  zeigt die Datei nicht). Das ist kein Formalismus, sondern die Regel selbst: ein Slice darf `LH-*`
  nicht ändern. Ergibt die Entscheidung eine nötige Lastenheft-Änderung, ist das ein **Folge-CR mit
  eigenem Trigger**, kein Nebeneffekt dieses Slice.
- [x] **Doc-Reconciliation:** die **aktiven** `v3.5.1`-Referenzen auf `v3.5.2` gezogen.
  **Zählung korrigiert (Verifikation A-1 / Review-Runde-2 N-3, bei `80eec58` nachgemessen):**
  **15 Vorkommen** in 4 Dateien — [`harness/conventions.md`](../../../../harness/conventions.md) 6×,
  [`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md) 3×,
  [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) 3×,
  [`roadmap.md`](../in-progress/roadmap.md) **3×** (nicht 1× — die Kandidaten-Zeile trägt zwei).
  Davon **11 gezogen**, **4 bewusst als historischer Bezug behalten** (Re-Baseline-Historie,
  Reviewer-1.3.0-Eintrag, zwei Roadmap-Nennungen des Bump-Ziels).
  **Ausgenommen** (unverändert): frozen `done/`-Slices + `docs/reviews/**` (Zeitdokumente),
  **accepted ADRs** (Hard Rule 3.4 immutable — historischer Bezug bleibt), der vendored Baum selbst
  (wird ersetzt). Diese Slice-Datei darf `v3.5.1` als **historischen** Bezug führen.
- [x] `make baseline-verify` grün: `v3.5.2 OK — 42 Dateien` (Integrität + Vollständigkeit, netzlos).
- [x] `make gates` grün (alle Gates auf dem re-vendored Stand).
- [x] `make mutate` grün. **Vorab-Befund (gemessen, s. §3):** kein Fall hardcodet Tag, Hash oder
  Asset-Größe — Fall 01 matcht generisch (`[0-9a-f]{64}`), 02/03/11/13/67 hängen an der Mechanik,
  nicht am Wert → **kein** Re-Anchoring erwartet. Die Go-Bump-Lehre bleibt: ein Wert-Bump zieht
  `make mutate` nach, die Erwartung ersetzt den Lauf nicht.
- [x] `make baseline-freshness` meldet danach **keinen** Drift mehr (Exit 0) — der Sensor, der diesen
  Slice ausgelöst hat, bestätigt seine eigene Auflösung.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-25, live belegt — nicht geschätzt):**

- `make baseline-freshness`: `VERALTET — gepinnt v3.5.1, latest v3.5.2`.
- Release-Asset `lab-regelwerk.zip` = **125180 Bytes**, sha256
  `2af45aad2777cadf26127066c9a2dc43f7111ee2687e44fe2eceb95c6c0a1925`.
- **42 Dateien** (21 regelwerk + 21 templates) — **gleicher Dateisatz** wie v3.5.1, 0 hinzugefügt,
  0 entfernt. **36 der 42 inhaltlich geändert.**
- **Von den 36 sind 33 reine Versions-/Welle-Stand-Bumps** (der Diff verschwindet, wenn man `v3.5.x`
  und `Welle N` normalisiert). **Substanziell geändert sind genau drei Dateien:**
  1. `regelwerk/README.md` — Stand-Zeile Kurs-Welle 33 → 34.
  2. `regelwerk/grundlagen-konventionen.md` — **+12 Zeilen, der einzige echte normative Zuwachs**
     (s. u.).
  3. `templates/spec/lastenheft.template.md` — +6 Zeilen Kommentar, der dieselbe Regel im Template
     verankert.
- 5 Pin-Stellen unverändert an ihren Orten: `BASELINE_TAG`/`BASELINE_ZIP_SHA256`
  ([`Makefile`](../../../../Makefile)), `DefaultTag`/`DefaultBaselineSHA256`
  ([`internal/fetch/baseline.go`](../../../../internal/fetch/baseline.go)), [`.d-check.yml`](../../../../.d-check.yml)-`sources` (url + sha256).
- Aktive Doc-Referenzen auf `v3.5.1`: 13 Vorkommen in 4 Dateien (Zählung in §2). **Diese
  Planungs-Messung war falsch — real 15** (`roadmap.md` trägt 3, nicht 1); korrigiert in §2, der
  Fehler wird hier stehen gelassen statt überschrieben. Alles Weitere liegt
  in `done/`, `docs/reviews/**` oder im vendored Baum.

**Normativer Delta — die eigentliche Arbeit.** v3.5.2 ergänzt in `grundlagen-konventionen.md`
sinngemäß: „Change Request" sei **bewusst kein Harness-Konstrukt** — kein `CR-*`-ID-Schema, keine
eigene Datei, kein Gate —, sondern der *externe* Vorgang, in dem eine Vertragsänderung mit dem
Auftraggeber vereinbart wird. Im Repo hinterlasse ein angenommener CR nur einen **Fußabdruck**:
Version-Bump des Lastenhefts, eine Zeile in dessen `## Historie` mit Verweis auf den externen CR,
und die geänderten Anforderungs-IDs selbst. Daraus folge die Hard Rule: **weder ADR noch Slice
dürfen Anforderungs-IDs je ändern** — sie referenzieren nur. (Wortlaut im vendored Baum nach dem
Re-Vendor; hier bewusst paraphrasiert, weil die Datei zum Planungszeitpunkt noch nicht im Repo liegt.)

Gegen die reale Praxis dieses Repos gehalten, drei Achsen — **zwei konform, eine offen:**

| Achse der neuen Regel | Ist-Stand hier | Urteil |
|---|---|---|
| kein `CR-*`-ID-Schema, keine CR-Datei, kein Gate | Die Historie führt `CR:`-Prosa, keine IDs, keine Dateien, kein Gate | **konform** |
| Fußabdruck = Version-Bump + `## Historie`-Zeile + geänderte Anforderungs-IDs | Genau so seit 0.1.0 (13 Zeilen, Spalte „Verweis" vorhanden) | **konform in der Form** |
| Verweis zeigt auf den **externen** CR; **kein Slice/ADR ändert Anforderungs-IDs** | Die Verweise zeigen nach **innen** (`slice-017-Folge`, `Messmethoden-CR`); die Zeile 0.13.0 trägt wörtlich „Getrieben von slice-048" | **offen — hier ist zu entscheiden** |

Die dritte Achse ist keine Schlamperei, sondern eine **Struktur-Eigenheit**: dieses Repo hat keinen
externen Auftraggeber, es ist sein eigener. Der Nutzer *ist* die Instanz, die den CR annimmt — bei
0.13.0 vor der Implementierung, „Schritt 0, Doc-führt vor Code". Zu entscheiden ist deshalb nicht
„haben wir die Regel gebrochen", sondern **wie der externe Vorgang aussieht, wenn Auftraggeber und
Entwickler dieselbe Person sind** — und woran man den Unterschied zwischen „der Slice hat das
Lastenheft geändert" und „der Auftraggeber hat einen CR angenommen, den ein Slice danach umsetzt"
*nachträglich noch erkennt*. Genau das muss ein `MR-*` festhalten.

**Die Falle, die dabei zu umgehen ist** (in der DoD verankert): die Regel besagt, dass ein Slice das
Lastenheft nicht ändern darf. Ein Slice, der zur Adoption dieser Regel das Lastenheft anfasst,
widerlegt sie im Vollzug. Dieser Slice fasst `spec/lastenheft.md` deshalb **nicht** an — was die
Entscheidung an [`harness/conventions.md`](../../../../harness/conventions.md) verweist (Rang 2, für einen Slice zulässig).

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/baseline/v3.5.2/**` <!-- d-check:ignore (geplant — entsteht beim Vendoren) --> | neu | entpackt aus dem Release-ZIP + `SHA256SUMS` neu erzeugt |
| `.harness/baseline/v3.5.1/**` | entfernt | ein Tag zur Zeit ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 4) |
| [`Makefile`](../../../../Makefile) | update | `BASELINE_TAG`, `BASELINE_ZIP_SHA256` |
| [`internal/fetch/baseline.go`](../../../../internal/fetch/baseline.go) | update | `DefaultTag`, `DefaultBaselineSHA256` (Kopplungstests halten) |
| [`.d-check.yml`](../../../../.d-check.yml) | update | `sources`-url + sha256 (Kopplung [`test/sources-pin.bats`](../../../../test/sources-pin.bats)) |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | Baseline-Stand + **CR-Regel-Entscheidung** (Adaptions-Eintrag oder neuer `MR-*`) |
| aktive Doc-Dateien (§2-Liste) | update | `v3.5.1`→`v3.5.2`, frozen/ADR/vendored ausgenommen |
| [`roadmap.md`](../in-progress/roadmap.md) | update | Tag-Bezug + Stand-Drift (führt [slice-047](slice-047-mutate-host-isolation.md) noch als `in-progress`, kennt [slice-048](slice-048-release-artefakte.md) nicht) |
| `spec/lastenheft.md` | **unberührt** | die adoptierte Regel verbietet es diesem Slice (s. o.) |

**Reihenfolge:** (1) Provenienz prüfen → vendoren → `SHA256SUMS` → alter Baum raus → Pins →
`make baseline-verify` grün. (2) Normativen Delta entscheiden und in [`harness/conventions.md`](../../../../harness/conventions.md)
festschreiben. (3) Doc-Reconciliation → `make gates` grün. (4) `make mutate` + `make baseline-freshness`.

## 4. Trigger

**`open` → `in-progress` (Implementer beginnt):** `make baseline-freshness` meldet `v3.5.1 < v3.5.2`
(am 2026-07-25 real gemessen, Ausgabe in §3). Keine aktive Welle, kein Vorgänger blockiert. Dieser
Slice ist **Schritt 1 des Release-Wegs** (Re-Baseline → Doku-Nachzug → Tag `v0.1.0`, Reihenfolge vom
Nutzer bestätigt): er zieht zuerst, damit `v0.1.0` einen aktuellen Regelwerks-Stand ausliefert und
nicht direkt nach dem Release veraltet.

Rückführungen:

- `in-progress` → `next`: falls die CR-Regel-Entscheidung einen eigenen ADR braucht (statt eines
  `MR-*`) — dann Vendor+Pins von der Normativ-Entscheidung trennen, weil ein ADR eine eigene
  Architect-Runde ist und nicht in denselben Review passt.
- `in-progress` → `open`: falls das Release-Asset nicht verifizierbar ist, oder falls die
  CR-Regel-Entscheidung eine **Lastenheft**-Änderung erzwingt — die darf dieser Slice nicht
  vornehmen (Carveout, Modul 7; der CR ist dann ein eigener Vorgang mit eigenem Trigger).

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt die DoD (Modul 11);
`make baseline-verify` + `make gates` + `make mutate` + `make baseline-freshness` grün; Slice per
`git mv` nach `done/` (eigener Move-Commit, eingehende Links im selben Zug repariert); Closure-Notiz
mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der normative Delta ist klein, aber nicht harmlos.** 33 der 36 geänderten Dateien sind
  Versions-Bumps; die Aufmerksamkeit gehört den drei substanziellen. Das Risiko ist nicht „viel
  Neues", sondern **eine Regel, die im Rauschen von 36 geänderten Dateien untergeht** — genau die
  Klasse, gegen die die Ist-Messung in §3 gefahren wurde.
- **Die CR-Regel trifft eine Praxis, die dieses Repo 13-mal ausgeübt hat.** Die Entscheidung wirkt
  rückwärts auf die Lesart der Historie-Zeilen 0.2.0–0.13.0. Sie darf diese Zeilen **nicht
  umschreiben** (das wäre eine Slice-getriebene Lastenheft-Änderung) — sie ordnet sie nur ein.
- **Externe Kurs-URLs sind nicht d-check-geprüft** (netzlos). Ein `.../blob/v3.5.1/...`→`v3.5.2`-Bump
  bricht `docs-check` nicht, aber die Ziel-Anker müssen im v3.5.2-Kurs real existieren — beim Bumpen
  stichprobenartig prüfen.
- **ADR-Immutabilität (Hard Rule 3.4).** Accepted ADRs tragen `v3.5.x` als historischen Bezug —
  **nicht** editieren.
- **`SHA256SUMS`-Selbstausschluss.** Die Datei kann sich nicht selbst hashen; ihre Integrität trägt
  git ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 2) — beim Erzeugen ausnehmen, sonst schlägt `baseline-verify` fehl.
- **Der emittierte Template-Baum ändert sich mit.** `templates/spec/lastenheft.template.md` bekommt
  den neuen Kommentarblock; ein Ziel-Repo erbt ihn ab diesem Bump. Kein Test hardcodet Dateizahl oder
  Template-Inhalt (gemessen) — aber `make smoke`/`make full-smoke` sind der Beleg dafür, nicht die
  Annahme.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

**Was hat funktioniert.** Die Mechanik lief sauber und ohne Überraschung: Provenienz **vor** dem
Entpacken geprüft (125180 Bytes, `2af45aad…1925` — identisch mit dem Planungswert), `SHA256SUMS`
neu erzeugt, alter Baum raus, `baseline-verify: v3.5.2 OK — 42 Dateien`. Die fünf gekoppelten Pins
hielten (Kopplungstests + [`test/sources-pin.bats`](../../../../test/sources-pin.bats) grün). Der **normative Delta wurde gemessen
statt geschätzt**: 33 der 36 geänderten Dateien sind reine Versions-/Welle-Bumps (nach
Normalisierung leerer Diff), substanziell sind exakt die drei geplanten. `make mutate` 81 ok/0 ohne
Re-Anchoring — die Vorab-Erwartung traf, der Lauf ersetzte sie trotzdem nicht. `make full-smoke`
belegte den geerbten Template-Baum real; die **Verifikation wiederholte ihn mit ausdrücklicher
Begründung** (er liegt nicht in `gates`, der Implementer-Lauf ist also eine Behauptung ohne
deckenden Gate-Lauf) und zog zusätzlich die **Provenienz-Kette unabhängig nach**: Asset geholt,
entpackt, `diff -rq` gegen den vendorten Baum byte-identisch. Damit ist mehr belegt, als die DoD
verlangt — die Grenze, die der Review offenlassen musste, ist geschlossen.

**Was anders lief als geplant.** Die inhaltliche Achse kostete **vier Review-Runden** — und zwar
nicht, weil die Regel falsch war, sondern weil **ihre Ist-Belege viermal auf dieselbe Weise falsch
waren**:

1. **F-1 (HIGH):** [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2 nannte `git log` + `git show --stat` als Nachweis-Verfahren
   und behauptete, die Messung bestätige die Praxis — geprüft war aber nur das Commit-**Präfix**,
   nicht die **Datei-Menge**. Real: 16 Commits berühren `spec/lastenheft.md`, 6 ändern sie allein,
   10 bündeln.
2. **N-1 (HIGH):** „die Praxis wurde nie ausgeübt" — universelles Negativ aus zwei Stichproben,
   widerlegt durch einen Commit, der 7 Inbound-Links über 5 Dateien im selben Move zieht.
3. **N-3 (LOW):** eine falsche Zählung (13) durch eine ebenfalls falsche (13/11/2) ersetzt; real
   **15/11/4**.
4. **R-1 (MEDIUM):** „kein Dokument schreibt sie" — wieder ein ungeprüfter Allquantor;
   [`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md) schreibt die Konvention und löst sie **gegenläufig**
   zur Kandidaten-Formulierung auf (eigener Reconciliation-Commit **nach** dem Move).

Die **Setzung selbst** überstand jede Runde unbeschädigt; gefallen sind nur ihre Ist-Aussagen. Diese
Trennung — normativer Gehalt vs. behaupteter Ist-Zustand — ist die eigentliche Lehre des Slice.
Alle vier falschen Sätze bleiben in den Zeitdokumenten **stehen und markiert**, statt geglättet zu
werden.

**Steering-Loop-Eintrag** (kanonische Definition:
[`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/klassifikation.md#steering-loop)):

- **[`AGENTS.md`](../../../../AGENTS.md) §3.6 schärfen — der Guide kennt den Träger nicht, an dem er hier viermal
  gerissen ist.** Seine Aufzählung nennt Doc-Kommentar, Test-Name, DoD-Punkt und Commit-Message,
  aber **nicht die Ist-Messung in Prosa** (Konventions-, Planungs- und Report-Text). Die kleinste
  tragende Schärfung: *ein Allquantor über einen Repo-Zustand trägt den Befehl, der ihn misst, neben
  sich — Kommando, Suchraum und Ergebnis.* Vier Instanzen in einer Sitzung, drei davon Allquantoren.
- **Der Sensor-Bauplan liegt schon in der Roadmap:** der Kandidat *Prosa-Zahlen-Provenienz* deckt
  mit derselben Mechanik Wörter statt Zahlen ab — er braucht keine neue Achse, nur eine Ausweitung.
- **Reviewer-Skill:** der Suchraum gehört um `.claude/commands/` und `internal/emit/templates/`
  erweitert. Dort lag der Gegenbeleg zu R-1 — und Runde 2 hat ihn ebenfalls verfehlt, der blinde
  Fleck ist also nicht rollen-spezifisch.
- **Der Slice ist sein eigener Beleg:** eine Regel ohne Sensor altert nicht erst später. [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  wurde in **derselben Sitzung** viermal falsch belegt, während niemand sie falsch *anwenden*
  konnte — es gab nichts anzuwenden. Feedforward ohne Feedback verfällt sofort, nicht mit der Zeit.

**Folge-Kandidaten** (bewusst **nicht** geschnitten — cp-Disziplin: Plandatei erst, wenn der erste
Slice steht):

- **Regeln ohne Feedback-Quadrant schließen.** Fünf gemessene Instanzen; für **vier** liefert
  d-check den Sensor bereits mit (`targets` für Hard Rule 3.1/[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), `vcs` für Hard Rule 3.4,
  `commits` für die ID-Zusage aus [`harness/README.md`](../../../../harness/README.md) §Traceability, `planning` für
  Roadmap↔`in-progress`). Nur die Co-Change-Regel aus [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) braucht einen Eigenbau
  (Cutoff ab diesem Eintrag; fail-closed bei Shallow Clone — `actions/checkout` holt per Default
  Tiefe 1, ein History-Sensor wäre dort blind **und grün**). Runde-4-Befund V-1 bestätigt die
  Verfügbarkeit: `doc-immutable`/`doc-commits` sind range-fähig und bereits verdrahtet, nur an
  keinen Trigger gehängt.
- **Lifecycle-Move-Konvention** (Roadmap-Kandidat, Achse 4): **zuerst den Widerspruch klären** (ein
  Commit oder zwei?), dann auf die Slice-Moves ausdehnen — heute schreibt sie nur der
  Welle-Closure-Command, und bewacht ist sie in keinem Fall.
- **Verlorener Kandidat** (Runde-4-Befund V-2): die Zählung „`done/`-Link-Churn — 7. Instanz,
  ÜBERFÄLLIG" steht in [welle-03-results.md](welle-03-results.md) und [slice-024](slice-024-voll-smoke.md), ihr Backlog-Kandidat
  („Cluster D", gegenläufige Lösungsrichtung) ist in der Roadmap **nicht mehr auffindbar**. Ein
  verlorener Kandidat ist selbst eine Befundklasse.
- **M5 Schritt 2:** Doku-Nachzug — [README](../../../../README.md) und [Benutzerhandbuch](../../../user/benutzerhandbuch.md) behaupten weiter „keine
  vorgefertigten Release-Binaries".

**Verifikation und Review.** DoD **BESTÄTIGT** 10/10 mit selbst erhobenen Belegen
([Verifikations-Report](../../../reviews/2026-07-26-slice-049-verification.md)); Review **KONFORM** in Runde 4 (0 HIGH, 0 MEDIUM;
[Runde 1](../../../reviews/2026-07-26-slice-049-impl-review.md) · [Runde 2](../../../reviews/2026-07-26-slice-049-impl-review-runde-2.md) ·
[Runde 3](../../../reviews/2026-07-26-slice-049-impl-review-runde-3.md) · [Runde 4](../../../reviews/2026-07-26-slice-049-impl-review-runde-4.md)).

## 8. Sub-Area-Modus-Begründung

### Sub-Area: vendored Baseline (`.harness/baseline/` + Pins + Kopplungstests)

- **Modus:** BF — die Sub-Area existiert (der committet-vendored Mechanismus aus
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), die Kopplungstests, `baseline-verify`); dieser Slice **re-vendored** sie, baut nicht neu.
- **Konventionen-Dichte:** hoch. [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) fixiert vier Setzungen (Provenienz≠Integrität,
  `SHA256SUMS`-Umfang, Vollständigkeits-Check, ein Tag zur Zeit); [`MR-013`](../../../../harness/conventions.md#mr-013--regelwerk-check-auf-d-check-sources-tool-statt-skript) die Zwei-Pin-Kopplung.
  Der Re-Vendor **erbt** sie, erfindet sie nicht neu ([slice-043](slice-043-baseline-bump-v3.5.1.md) ist der gefahrene Präzedenzfall).
- **Phase-Reife:** Phase 4 (reif). Der Re-Vendor ist wiederkehrende Wartung; die Mechanik lief
  einmal sauber durch.
- **Evidenz-/Diskrepanz-Risiko:** **mittel-hoch, und diesmal konkret** — anders als bei
  [slice-043](slice-043-baseline-bump-v3.5.1.md) ist die Konventions-Kollision nicht hypothetisch, sondern gemessen (CR-Regel gegen
  13 Historie-Zeilen). Sie ist der Grund, warum dieser Slice die volle Rollen-Sequenz fährt und nicht
  als Pin-Bump durchgewinkt wird.
- **Reconciliation-Aufwand:** ein Slice. **Graduation-Trigger:** falls die CR-Regel-Entscheidung
  einen ADR statt eines `MR-*` verlangt, oder falls sie eine Lastenheft-Änderung erzwingt — dann
  Vendor+Pins hier abschließen und die Normativ-Achse als eigenen Slice/CR führen (Rückführung §4).
